protocol UserLogin: Sendable {
    func login(userId: EntityId, funcId: String, customCtxJson: String?) async
    func logout(userId: EntityId) async
}
