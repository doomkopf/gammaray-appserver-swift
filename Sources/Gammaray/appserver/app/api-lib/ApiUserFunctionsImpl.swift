struct ApiUserFunctionsImpl: ApiUserFunctions {
    let jsonEncoder: StringJSONEncoder
    let userLogin: UserLogin
    let appUserLogin: AppUserLogin
    let userSender: UserSender

    func send(userId: EntityId, obj: Encodable & Sendable) {
        Task {
            await userSender.send(userId: userId, payload: obj)
        }
    }

    func login(
        userId: EntityId,
        loginFinishedFunctionId: String,
        ctxPayload: (Encodable & Sendable)?,
        ctx: ApiRequestContext,
    ) {
        Task {
            var ctxPayloadStr: String?
            if let ctxPayload {
                ctxPayloadStr = jsonEncoder.encode(ctxPayload)
            }
            await appUserLogin.login(
                userId: userId,
                loginFinishedFunctionId: loginFinishedFunctionId,
                ctxPayload: ctxPayloadStr,
                ctx: RequestContext(
                    requestId: ctx.requestId,
                    requestingUserId: ctx.requestingUserId,
                    clientRequestId: ctx.clientRequestId,
                    persistentSession: (ctx as! ApiRequestContextImpl).persistentSession,
                ),
            )
        }
    }

    func logout(userId: EntityId) {
        Task {
            await userLogin.logout(userId: userId)
        }
    }
}
