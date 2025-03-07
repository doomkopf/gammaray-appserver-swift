protocol UserLogin: Sendable {
    func login(userId: EntityId) async -> SessionId
    func logout(userId: EntityId) async
}
