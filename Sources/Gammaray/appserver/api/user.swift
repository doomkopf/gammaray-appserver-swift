protocol UserFunctions: Sendable {
    func send(userId: EntityId, params: Encodable)
    func login(userId: EntityId, loginFinishedFunctionId: String, customCtx: Encodable?)
    func logout(userId: EntityId)
}

struct LoginResult: Codable {
    let sessionId: String
    let ctxJson: String?
}
