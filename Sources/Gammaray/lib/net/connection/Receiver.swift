import NIO

final class Handler: ChannelInboundHandler, Sendable {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let input = unwrapInboundIn(data)
        guard
            let message = input.getString(at: 0, length: input.readableBytes)
        else {
            return
        }

        var buff = context.channel.allocator.buffer(capacity: message.count)
        buff.writeString(message)
        context.write(wrapOutboundOut(buff), promise: nil)
    }

    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print(error)
        context.close(promise: nil)
    }
}

class Receiver {
    private let eventLoopGroup: EventLoopGroup

    init(port: Int, listener: ReceptionListener) throws {
        eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let serverBootstrap = ServerBootstrap(group: eventLoopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.addHandlers([
                    Handler()
                ])
            }
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(
                ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())

        _ = try serverBootstrap.bind(host: "127.0.0.1", port: port).wait()
    }

    func shutdown() throws {
        try eventLoopGroup.syncShutdownGracefully()
    }
}
