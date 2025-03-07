actor UserLogin {
    private var idCounter = 0
    private let sessionId2UserIdCache: any Cache<EntityId>
    private let task: ScheduledTask

    init(
        scheduler: Scheduler
    ) throws {
        sessionId2UserIdCache = try CacheImpl(
            entryEvictionTimeMillis: 1_800_000, maxEntries: 100000)
        task = scheduler.scheduleInterval(millis: 5000)

        task.setFuncNotAwaiting {
            await self.cleanup()
        }
    }

    private func cleanup() {
        sessionId2UserIdCache.cleanup()
    }

    func login(userId: EntityId) -> SessionId {
        let sessionId = generateSessionId()
        sessionId2UserIdCache.put(key: sessionId, value: userId)
        return sessionId
    }

    func logout(userId: EntityId) {
    }

    private func generateSessionId() -> SessionId {
        idCounter += 1
        return SessionId(idCounter)
    }

    func shutdown() async {
        await task.cancel()
    }
}
