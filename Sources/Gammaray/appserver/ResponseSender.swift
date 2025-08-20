actor ResponseSender: CacheListener {
    private let log: Logger

    private var idCounter = 0
    private let requestsCache: any Cache<RequestId, GammarayProtocolRequest>
    private let task: ScheduledTask

    init(
        loggerFactory: LoggerFactory,
        scheduler: Scheduler,
        requestsCache: any Cache<RequestId, GammarayProtocolRequest>
    ) {
        log = loggerFactory.createForClass(ResponseSender.self)

        self.requestsCache = requestsCache
        task = scheduler.scheduleInterval(millis: 5000)

        requestsCache.setListener(self)
        task.setFuncNotAwaiting {
            await self.cleanup()
        }
    }

    init(
        loggerFactory: LoggerFactory,
        scheduler: Scheduler
    ) throws {
        self.init(
            loggerFactory: loggerFactory,
            scheduler: scheduler,
            requestsCache: try CacheImpl(entryEvictionTimeMillis: 10000, maxEntries: 100000))
    }

    private func cleanup() {
        requestsCache.cleanup()
    }

    func send(requestId: RequestId, payload: String) async {
        guard let request = requestsCache.remove(requestId) else {
            return
        }

        await request.respond(payload: payload)
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
