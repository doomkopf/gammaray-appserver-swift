actor ApiUserFunctionsImpl: ApiUserFunctions {
    private let userSender: UserSender
    private let userLogin: UserLogin
    private let jsonEncoder: StringJSONEncoder
    private var statelessFuncs: StatelessFunctions?

    init(
        userSender: UserSender,
        userLogin: UserLogin,
        jsonEncoder: StringJSONEncoder
    ) {
        self.userSender = userSender
        self.userLogin = userLogin
        self.jsonEncoder = jsonEncoder
    }

    func lateBind(statelessFuncs: StatelessFunctions) {
        self.statelessFuncs = statelessFuncs
    }

    nonisolated func send(userId: EntityId, obj: String) {
        Task {
            await userSender.send(userId: userId, objJson: obj)
        }
    }

    nonisolated func login(
        userId: EntityId,
        loginFinishedFunctionId: String,
        customCtx: String?
    ) {
        let ctx = RequestContextContainer.$ctx.get()

        Task {
            await login(
                userId: userId,
                loginFinishedFunctionId: loginFinishedFunctionId,
                ctxJson: customCtx,
                ctx: ctx
            )
        }
    }

    func login(
        userId: EntityId,
        loginFinishedFunctionId: String,
        ctxJson: String?,
        ctx: RequestContext
    ) async {
        guard let statelessFuncs else {
            return
        }

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

    nonisolated func logout(userId: EntityId) {
        Task {
            await userLogin.logout(userId: userId)
        }
    }
}
