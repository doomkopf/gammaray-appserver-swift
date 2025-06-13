enum RequestErrorResultType {
    case TIMEOUT
    case ERROR
}

struct RequestResult {
    let error: RequestErrorResultType?
    let data: String?
}

typealias ResultCallback = @Sendable (_ result: RequestResult) -> Void

actor ResultCallbacks: CacheListener {
    private let cache: any Cache<ResultCallback>
    private let cacheCleanTask: ScheduledTask

    init(requestTimeoutMillis: Int64, scheduler: Scheduler) throws {
        cache = try CacheImpl<ResultCallback>(
            entryEvictionTimeMillis: requestTimeoutMillis,
            maxEntries: 100000
        )
        cacheCleanTask = scheduler.scheduleInterval(millis: 500)

        cache.setListener(self)
        cacheCleanTask.setFuncNotAwaiting {
            await self.cleanCache()
        }
    }

    private func cleanCache() {
        cache.cleanup()
    }

    nonisolated func onEntryEvicted(key: String, value: ResultCallback) {
        value(RequestResult(error: .TIMEOUT, data: nil))
    }

    func remove(_ requestId: String) -> ResultCallback? {
        return cache.remove(requestId)
    }

    func put(requestId: String, callback: @escaping ResultCallback) {
        cache.put(key: requestId, value: callback)
    }

    func shutdown() async {
        await cacheCleanTask.cancel()
    }
}
