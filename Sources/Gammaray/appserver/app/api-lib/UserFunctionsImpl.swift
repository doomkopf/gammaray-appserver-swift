struct UserFunctionsImpl: UserFunctions {
    let userSender: UserSender
    let userLogin: UserLogin
    let jsonEncoder: StringJSONEncoder
    let statelessFuncs: StatelessFunctions

    func send(userId: EntityId, params: Encodable) {
        let objJson = jsonEncoder.encode(params)
        Task {
            await userSender.send(userId: userId, objJson: objJson)
        }
    }

    func login(userId: EntityId, loginFinishedFunctionId: String, customCtx: Encodable?) {
        let ctx = RequestContextContainer.$ctx.get()

        let ctxJson: String?
        if let customCtx {
            ctxJson = jsonEncoder.encode(customCtx)
        } else {
            ctxJson = nil
        }

        Task {
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

    func logout(userId: EntityId) {
        Task {
            await userLogin.logout(userId: userId)
        }
    }
}
