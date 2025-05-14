struct AppUserLogin {
    let userLogin: UserLogin
    let statelessFuncs: StatelessFunctions
    let jsonEncoder: StringJSONEncoder

    func login(
        userId: EntityId,
        loginFinishedFunctionId: String,
        ctxJson: String?,
        ctx: RequestContext
    ) async {
        let sessionId = await userLogin.login(userId: userId)
        let loginResult = LoginResult(
            sessionId: sessionId,
            ctxJson: ctxJson
        )
        await statelessFuncs.invoke(
            FunctionParams(
                theFunc: loginFinishedFunctionId,
                ctx: ctx,
                paramsJson: jsonEncoder.encode(loginResult)
            )
        )
    }
}
