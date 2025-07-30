actor UserLogin: CacheListener {
    private let userSender: UserSender
    private var idCounter = 0
    private let sessionId2UserIdCache: any Cache<EntityId>
    private var userId2SessionId: [String: SessionId] = [:]
    private let task: ScheduledTask

    init(
        userSender: UserSender,
        scheduler: Scheduler,
    ) throws {
        self.userSender = userSender

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

    func login(userId: EntityId, persistentSession: GammarayPersistentSession?) async -> SessionId {
        let sessionId = generateSessionId()
        sessionId2UserIdCache.put(key: sessionId, value: userId)
        userId2SessionId[userId.value] = sessionId
        if let persistentSession {
            await userSender.putUserSession(session: persistentSession, userId: userId)
        }
        return sessionId
    }

    func getUserId(sessionId: SessionId) -> EntityId? {
        sessionId2UserIdCache.get(key: sessionId)
    }

    func logout(userId: EntityId) async {
        if let sessionId = userId2SessionId[userId.value] {
            await remove(sessionId: sessionId, userId: userId)
        }
    }

    private func remove(sessionId: SessionId, userId: EntityId) async {
        _ = sessionId2UserIdCache.remove(sessionId)
        userId2SessionId.removeValue(forKey: userId.value)
        await userSender.removeUserSession(userId: userId)
    }

    private func generateSessionId() -> SessionId {
        idCounter += 1
        return SessionId(idCounter)
    }

    func shutdown() async {
        await task.cancel()
    }
}
