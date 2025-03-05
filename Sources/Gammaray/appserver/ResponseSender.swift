actor ResponseSender: CacheListener {
    typealias V = GammarayProtocolRequest

    private var idCounter = 0
    private let requestsCache: any Cache<GammarayProtocolRequest>
    private let task: ScheduledTask

    init(
        scheduler: Scheduler,
        requestsCache: any Cache<GammarayProtocolRequest>
    ) {
        self.requestsCache = requestsCache
        task = scheduler.scheduleInterval(millis: 5000)

        requestsCache.setListener(self)
        task.setFuncNotAwaiting {
            await self.cleanup()
        }
    }

    init(
        scheduler: Scheduler
    ) throws {
        self.init(
            scheduler: scheduler,
            requestsCache: try CacheImpl(entryEvictionTimeMillis: 10000, maxEntries: 100000))
    }

    private func cleanup() {
        requestsCache.cleanup()
    }

    func send(requestId: RequestId, objJson: String) async {
        guard let request = requestsCache.remove(requestId) else {
            return
        }

        await request.respond(payload: objJson)
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

    nonisolated func onEntryEvicted(key: String, value: V) {
        Task {
            await value.cancel()
        }
    }

    func shutdown() async {
        await task.cancel()
    }
}
