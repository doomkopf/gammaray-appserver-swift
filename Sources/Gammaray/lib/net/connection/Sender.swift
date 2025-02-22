import NIO

actor SenderHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    private let receptionListener: ReceptionListener
    private var buffer: InboundIn! = nil

    init(_ receptionListener: ReceptionListener) {
        self.receptionListener = receptionListener
    }

    nonisolated func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let buffer = unwrapInboundIn(data)
        Task {
            await isolatedChannelRead(inBuffer: buffer)
        }
    }

    private func isolatedChannelRead(inBuffer: InboundIn) {
        var mutableBuffer = inBuffer
        if buffer == nil {
            buffer = mutableBuffer
        } else {
            buffer.writeBuffer(&mutableBuffer)
        }

        if let frame = buffer.readNullTerminatedString() {
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
