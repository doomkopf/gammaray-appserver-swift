enum SendErrorType {
    case ERROR
    case TIMEOUT
}

struct SendError {
    let type: SendErrorType
    let causedBy: Error?
}

typealias SendCallback = @Sendable (_ err: SendError?) -> Void

struct SendQueueEntry: Sendable {
    let frame: String
    let callback: SendCallback
}

@available(macOS 10.15, *)
actor SendQueue: CacheListener {
    typealias V = SendQueueEntry

    private let cache: Cache<SendQueueEntry>
    private var cacheCleanTask: ScheduledTask?

    private var keyCounter = 0

    init(sendTimeoutMillis: Int64) throws {
        cache = try Cache<SendQueueEntry>(
            entryEvictionTimeMillis: sendTimeoutMillis, maxEntries: 100000)
        cache.setListener(self)
    }

    func start(scheduler: Scheduler) {
        cacheCleanTask = scheduler.scheduleInterval(millis: 500) {
            await self.cleanCache()
        }
    }

    private func cleanCache() {
        cache.cleanup()
    }

    nonisolated func onEntryEvicted(key: String, value: SendQueueEntry) {
        value.callback(SendError(type: .TIMEOUT, causedBy: nil))
    }

    func enqueue(_ elem: SendQueueEntry) {
        cache.put(key: String(keyCounter), value: elem)

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
        await cacheCleanTask?.cancel()
    }
}
