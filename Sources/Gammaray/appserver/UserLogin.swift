actor UserLogin: CacheListener {
    private var idCounter = 0
    private let sessionId2UserIdCache: any Cache<EntityId>
    private var userId2SessionId: [String: SessionId] = [:]
    private let task: ScheduledTask

    init(
        scheduler: Scheduler
    ) throws {
        sessionId2UserIdCache = try CacheImpl(
            entryEvictionTimeMillis: 1_800_000, maxEntries: 100000)
        task = scheduler.scheduleInterval(millis: 5000)
        sessionId2UserIdCache.setListener(self)

        task.setFuncNotAwaiting {
            await self.cleanup()
        }
    }

    private func cleanup() {
        sessionId2UserIdCache.cleanup()
    }

    nonisolated func onEntryEvicted(key: String, value: EntityId) {
        Task {
            await remove(sessionId: key, userId: value)
        }
    }

    func login(userId: EntityId) -> SessionId {
        let sessionId = generateSessionId()
        sessionId2UserIdCache.put(key: sessionId, value: userId)
        userId2SessionId[userId.value] = sessionId
        return sessionId
    }

    func logout(userId: EntityId) {
        if let sessionId = userId2SessionId[userId.value] {
            remove(sessionId: sessionId, userId: userId)
        }
    }

    private func remove(sessionId: SessionId, userId: EntityId) {
        _ = sessionId2UserIdCache.remove(sessionId)
        userId2SessionId.removeValue(forKey: userId.value)
    }

    private func generateSessionId() -> SessionId {
        idCounter += 1
        return SessionId(idCounter)
    }

    func shutdown() async {
        await task.cancel()
    }
}
