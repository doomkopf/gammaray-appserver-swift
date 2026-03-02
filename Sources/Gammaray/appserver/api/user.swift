protocol ApiUserFunctions: Sendable {
    func send(userId: EntityId, obj: Encodable & Sendable)
    func login(
        userId: EntityId,
        loginFinishedFunctionId: FunctionName,
        ctxPayload: (Encodable & Sendable)?,
        ctx: ApiRequestContext,
    )
    func logout(userId: EntityId)
}

struct LoginResult: Codable {
    let sessionId: String
    let ctxPayload: String?
}
