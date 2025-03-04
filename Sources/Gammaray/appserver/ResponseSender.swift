actor ResponseSender: CacheListener {
    typealias V = GammarayProtocolRequest

    private var idCounter = 0
    private let requests: any Cache<GammarayProtocolRequest>
    private let task: ScheduledTask

    init(
        scheduler: Scheduler
    ) throws {
        requests = try CacheImpl(entryEvictionTimeMillis: 10000, maxEntries: 100000)
        task = scheduler.scheduleInterval(millis: 5000)

        requests.setListener(self)
        task.setFuncNotAwaiting {
            await self.cleanup()
        }
    }

    private func cleanup() {
        requests.cleanup()
    }

    func send(requestId: RequestId, objJson: String) async {
        guard let request = requests.remove(requestId) else {
            return
        }

        await request.respond(payload: objJson)
    }

    func addRequest(request: GammarayProtocolRequest) -> RequestId {
        let requestId = generateRequestId()
        requests.put(key: requestId, value: request)
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
