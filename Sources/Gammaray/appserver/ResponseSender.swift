actor ResponseSender: CacheListener {
    private let log: Logger
    private let jsonEncoder: StringJSONEncoder

    private var idCounter = 0
    private let requestsCache: any Cache<RequestId, GammarayProtocolRequest>
    private let task: ScheduledTask

    init(
        loggerFactory: LoggerFactory,
        jsonEncoder: StringJSONEncoder,
        scheduler: Scheduler,
        requestsCache: any Cache<RequestId, GammarayProtocolRequest>
    ) {
        log = loggerFactory.createForClass(ResponseSender.self)
        self.jsonEncoder = jsonEncoder

        self.requestsCache = requestsCache
        task = scheduler.scheduleInterval(millis: 5000)

        requestsCache.setListener(self)
        task.setFuncNotAwaiting {
            await self.cleanup()
        }
    }

    init(
        loggerFactory: LoggerFactory,
        jsonEncoder: StringJSONEncoder,
        scheduler: Scheduler
    ) throws {
        self.init(
            loggerFactory: loggerFactory,
            jsonEncoder: jsonEncoder,
            scheduler: scheduler,
            requestsCache: try CacheImpl(entryEvictionTimeMillis: 10000, maxEntries: 100000))
    }

    private func cleanup() {
        requestsCache.cleanup()
    }

    func send(requestId: RequestId, payload: Encodable) async {
        guard let request = requestsCache.remove(requestId) else {
            return
        }

        await request.respond(payload: jsonEncoder.encode(payload))
        if log.isLevel(.DEBUG) {
            log.log(.DEBUG, "RESP - requestId=\(requestId) payload=\(payload)", nil)
        }
    }

    func addRequest(request: GammarayProtocolRequest) -> RequestId {
        let requestId = generateRequestId()
        requestsCache.put(key: requestId, value: request)
        return requestId
    }

    private func generateRequestId() -> RequestId {
        idCounter += 1
        return RequestId(idCounter)
    }

    nonisolated func onEntryEvicted(key: String, value: GammarayProtocolRequest) {
        Task {
            await value.cancel()
        }
    }

    func shutdown() async {
        await task.cancel()
    }
}
