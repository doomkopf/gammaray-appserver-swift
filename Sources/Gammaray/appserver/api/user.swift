protocol UserFunctions: Sendable {
    func send(userId: EntityId, objJson: String)
    func login(userId: EntityId, loginFinishedFunctionId: String, customCtxJson: String?)
    func logout(userId: EntityId)
}

struct LoginResult: Encodable, Decodable {
    let sessionId: String
    let ctxJson: String?
}
