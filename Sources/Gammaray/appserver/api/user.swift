protocol ApiUserFunctions: Sendable {
    func send(userId: EntityId, obj: String)
    func login(
        userId: EntityId,
        loginFinishedFunctionId: String,
        customCtx: String?
    )
    func logout(userId: EntityId)
}

struct LoginResult: Codable {
    let sessionId: String
    let ctxJson: String?
}
