import NIO

class SenderHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    private let receptionListener: ReceptionListener
    private var buffer: InboundIn! = nil

    init(_ receptionListener: ReceptionListener) {
        self.receptionListener = receptionListener
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var mutableBuffer = unwrapInboundIn(data)

        if buffer == nil {
            buffer = mutableBuffer
        } else {
            buffer.writeBuffer(&mutableBuffer)
        }

        while let frame = buffer.readNullTerminatedString() {
            receptionListener.onReceived(source: ReceptionSource(), frame: frame)
        }
    }

    private func isolatedChannelRead(inBuffer: InboundIn) {
        var mutableBuffer = inBuffer
        if buffer == nil {
            buffer = mutableBuffer
        } else {
            buffer.writeBuffer(&mutableBuffer)
        }

        while let frame = buffer.readNullTerminatedString() {
            receptionListener.onReceived(source: ReceptionSource(), frame: frame)
        }
    }
}

actor Sender {
    private let host: String
    private let port: Int
    private let sendQueue: SendQueue
    private let eventLoopGroup: EventLoopGroup
    private let bootstrap: ClientBootstrap
    private let sendIntervalMillis: Int64

    private var connected = false
    private var connecting = false
    private var channel: Channel?
    private var sendTask: ScheduledTask

    init(
        host: String,
        port: Int,
        sendTimeoutMillis: Int64,
        sendIntervalMillis: Int64,
        scheduler: Scheduler,
        receptionListener: ReceptionListener
    ) throws {
        self.host = host
        self.port = port
        self.sendIntervalMillis = sendIntervalMillis

        sendQueue = try SendQueue(sendTimeoutMillis: sendTimeoutMillis, scheduler: scheduler)
        sendTask = scheduler.scheduleInterval(millis: sendIntervalMillis)

        eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        bootstrap = ClientBootstrap(group: eventLoopGroup)
            .channelOption(
                ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1
            )
            .channelInitializer { channel in
                /*
                The NIO design here makes no sense to me:
                A (ChannelHandler & Sendable) is expected here.
                The ChannelInboundHandler.channelRead is basically doing the frame decoding.
                One aspect of frame decoding is to store each chunk of data sequentially until we have a complete frame, but this requires a mutable state.
                So it expects a Sendable but a synchronous state mutation is usually needed, that's the conflict here to me.
                However, I'll assume for now that this method is only called by one thread at a time, so I will just ignore the concurrency warning here.
                */
                channel.pipeline.addHandler(SenderHandler(receptionListener))
            }

        sendTask.setFuncNotAwaiting {
            await self.checkSendQueueAndTryConnectAndSend()
        }
    }

    func send(_ frame: String) async -> SendError? {
        await withCheckedContinuation { c in
            sendCallback(frame: frame) { sendError in
                c.resume(returning: sendError)
            }
        }
    }

    func sendCallback(frame: String, callback: @escaping SendCallback) {
        Task {
            await sendQueue.enqueue(SendQueueEntry(frame: frame, callback: callback))
            await checkSendQueueAndTryConnectAndSend()
        }
    }

    private var isConnected: Bool {
        return channel != nil && connected
    }

    private var isConnecting: Bool {
        return connecting
    }

    private func connectIfNotConnected(callback: @Sendable @escaping (_ success: Bool) -> Void) {
        if isConnected {
            callback(true)
            return
        }

        if isConnecting {
            callback(false)
            return
        }

        let task = bootstrap.connect(host: host, port: port)
        connecting = true
        task.whenComplete { result in
            Task {
                do {
                    try await self.setConnected(channel: result.get())
                    callback(true)
                } catch {
                    callback(false)
                }
            }
        }
    }

    private func setConnected(channel: Channel) {
        self.channel = channel
        connecting = false
        connected = true
    }

    private func checkSendQueueAndTryConnectAndSend() async {
        if await !sendQueue.hasEntries {
            return
        }

        connectIfNotConnected { success in
            if success {
                Task {
                    await self.sendDirectAllFromQueue()
                }
            }
        }
    }

    private func sendDirectAllFromQueue() async {
        while let entry = await sendQueue.poll() {
            sendDirect(frame: entry.frame, callback: entry.callback)
        }
    }

    private func sendDirect(frame: String, callback: @escaping SendCallback) {
        channel?.writeAndFlush(stringToTerminatedBuffer(frame)).whenComplete { result in
            do {
                try result.get()
                callback(nil)
            } catch {
                callback(SendError(type: .ERROR, causedBy: error))
            }
        }
    }

    func shutdown() async throws {
        await sendTask.cancel()
        await sendQueue.shutdown()
        try await eventLoopGroup.shutdownGracefully()
    }
}
