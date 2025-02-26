// Thanks to Andy Finnell for the idea to use an AsyncStream: https://losingfight.com/blog/2024/04/14/modeling-condition-variables-in-swift-asyncawait/

struct WaitContext {
    private let waitClosure: @Sendable () async -> Void
    private let streamContinuation: AsyncStream<Void>.Continuation

    init() {
        let (stream, continuation) = AsyncStream<Void>.makeStream()
        waitClosure = {
            for await _ in stream {}
        }
        streamContinuation = continuation
    }

    func waitForSignal() async {
        await waitClosure()
    }

    func signal() {
        streamContinuation.finish()
    }
}
