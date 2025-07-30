protocol GammarayPersistentSession: Sendable {
    func send(payload: String) async
    func assignUserId(userId: EntityId) async
    func getUserId() async -> EntityId?
}
