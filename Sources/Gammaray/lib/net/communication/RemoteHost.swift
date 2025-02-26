struct RemoteHost {
    private let jsonEncoder = StringJSONEncoder()
    private let requestIdGenerator: RequestIdGenerator
    private let resultCallbacks: ResultCallbacks
    private let sender: Sender

    init(
        requestIdGenerator: RequestIdGenerator,
        resultCallbacks: ResultCallbacks,
        host: String,
        port: Int,
        sendTimeoutMillis: Int64,
        sendIntervalMillis: Int64,
        scheduler: Scheduler,
        listener: ReceptionListener
    ) throws {
        self.requestIdGenerator = requestIdGenerator
        self.resultCallbacks = resultCallbacks

        sender = try Sender(
            host: host,
            port: port,
            sendTimeoutMillis: sendTimeoutMillis,
            sendIntervalMillis: sendIntervalMillis,
            scheduler: scheduler,
            receptionListener: listener)
    }

    func request(cmd: Int, payload: String) async -> RequestResult {
        await withCheckedContinuation { c in
            requestCallback(cmd: cmd, payload: payload) { result in
                c.resume(returning: result)
            }
        }
    }

    private func requestCallback(cmd: Int, payload: String, callback: @escaping ResultCallback) {
        Task {
            let requestId = await requestIdGenerator.generate()

            await resultCallbacks.put(requestId: requestId, callback: callback)

            let command = requestCommand(cmd: cmd, id: requestId, pl: payload)
            let frame = jsonEncoder.encode(command)
            await sender.sendCallback(frame: frame) { optSendError in
                if let sendError = optSendError {
                    Task {
                        if let removedCallback = await self.resultCallbacks.remove(requestId) {
                            removedCallback(
                                RequestResult(
                                    error: self.mapError(sendError: sendError.type), data: nil))
                        }
                    }
                }
            }
        }
    }

    private func mapError(sendError: SendErrorType) -> RequestErrorResultType {
        switch sendError
        {
        case SendErrorType.TIMEOUT:
            return RequestErrorResultType.TIMEOUT
        case SendErrorType.ERROR:
            return RequestErrorResultType.ERROR
        }
    }

    func shutdown() async throws {
        try await sender.shutdown()
    }
}
