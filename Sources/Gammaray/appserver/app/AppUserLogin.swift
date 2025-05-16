struct AppUserLogin {
    let userLogin: UserLogin
    let statelessFuncs: StatelessFunctions
    let jsonEncoder: StringJSONEncoder

    func login(
        userId: EntityId,
        loginFinishedFunctionId: String,
        ctxPayload: String?,
        ctx: RequestContext
    ) async {
        let sessionId = await userLogin.login(userId: userId)
        let loginResult = LoginResult(
            sessionId: sessionId,
            ctxPayload: ctxPayload
        )
        await statelessFuncs.invoke(
            FunctionParams(
                theFunc: loginFinishedFunctionId,
                ctx: ctx,
                payload: jsonEncoder.encode(loginResult)
            )
        )
    }
}
