struct ApiUserFunctionsImpl: ApiUserFunctions {
    func send(userId: EntityId, obj: String) {
    }

    func login(
        userId: EntityId,
        loginFinishedFunctionId: String,
        ctxPayload: String?,
        ctx: RequestContext
    ) {
    }

    func logout(userId: EntityId) {
    }
}
