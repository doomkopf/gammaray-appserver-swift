actor UserSender {
    private var userId2Session: [String: GammarayPersistentSession] = [:]

    func send(userId: EntityId, payload: String) async {
        guard let session = userId2Session[userId.value] else {
            return
        }

        await session.send(payload: payload)
    }

    func putUserSession(session: GammarayPersistentSession, userId: EntityId) async {
        userId2Session[userId.value] = session
        await session.assignUserId(userId: userId)
    }

    func removeUserSession(userId: EntityId) {
        userId2Session.removeValue(forKey: userId.value)
    }
}
