protocol ApiUserFunctions: Sendable {
    func send(userId: EntityId, obj: String)
    func login(
        userId: EntityId,
        loginFinishedFunctionId: String,
        ctxPayload: String?,
        ctx: RequestContext
    )
    func logout(userId: EntityId)
}

struct LoginResult: Codable {
    let sessionId: String
    let ctxPayload: String?
}
