enum SendErrorType {
    case ERROR
    case TIMEOUT
}

struct SendError {
    let type: SendErrorType
    let causedBy: Error?
}

typealias SendCallback = @Sendable (_ err: SendError?) -> Void

struct SendQueueEntry {
    let frame: String
    let callback: SendCallback
}

actor SendQueue: CacheListener {
    private let cache: any Cache<Int, SendQueueEntry>
    private let cacheCleanTask: ScheduledTask

    private var keyCounter = 0

    init(sendTimeoutMillis: Int64, scheduler: Scheduler) throws {
        cache = try CacheImpl<Int, SendQueueEntry>(
            entryEvictionTimeMillis: sendTimeoutMillis, maxEntries: 100000)
        cacheCleanTask = scheduler.scheduleInterval(millis: 500)

        cache.setListener(self)
        cacheCleanTask.setFuncNotAwaiting {
            await self.cleanCache()
        }
    }

    private func cleanCache() {
        cache.cleanup()
    }

    nonisolated func onEntryEvicted(key: Int, value: SendQueueEntry) {
        value.callback(SendError(type: .TIMEOUT, causedBy: nil))
    }

    func enqueue(_ elem: SendQueueEntry) {
        cache.put(key: keyCounter, value: elem)

        keyCounter += 1
        if keyCounter > 999999 {
            keyCounter = 0
        }
    }

    func poll() -> SendQueueEntry? {
        guard let entry = cache.removeAnyEntry()
        else {
            return nil
        }

        return entry.v
    }

    var hasEntries: Bool {
        cache.size > 0
    }

    func shutdown() async {
        await cacheCleanTask.cancel()
    }
}
