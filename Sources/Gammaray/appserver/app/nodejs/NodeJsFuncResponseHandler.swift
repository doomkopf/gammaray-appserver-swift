protocol NodeJsFuncResponseHandler: Sendable {
    func handle(response: NodeJsFuncResponse, ctx: RequestContext) async
}

actor NodeJsFuncResponseHandlerImpl: NodeJsFuncResponseHandler {
    private let log: Logger
    private var appEntities: AppEntities?
    private var responseSender: ResponseSender?
    private var appUserLogin: AppUserLogin?
    private var userLogin: UserLogin?
    private var userSender: UserSender?
    private var httpClient: HttpClient?
    private var logger: Logger?

    init(loggerFactory: LoggerFactory) {
        log = loggerFactory.createForClass(NodeJsFuncResponseHandlerImpl.self)
    }

    func lateBind(
        appEntities: AppEntities,
        responseSender: ResponseSender,
        appUserLogin: AppUserLogin,
        userLogin: UserLogin,
        userSender: UserSender,
        httpClient: HttpClient,
        logger: Logger
    ) {
        self.appEntities = appEntities
        self.responseSender = responseSender
        self.appUserLogin = appUserLogin
        self.userLogin = userLogin
        self.userSender = userSender
        self.httpClient = httpClient
        self.logger = logger
    }

    func handle(response: NodeJsFuncResponse, ctx: RequestContext) async {
        await handle(response.responseSenderSend)
        await handle(response.userFunctionsLogin, ctx)
        await handle(response.userFunctionsLogout)
        await handle(response.userFunctionsSend)
        await handle(response.entityFunctionsInvoke, ctx)
        await handle(response.httpClientRequest)
        handle(response.loggerLog)
    }

    private func handle(_ rsPayload: NodeJsResponseSenderSend?) async {
        guard let responseSender else {
            return
        }
        if let rsPayload {
            await responseSender.send(
                requestId: rsPayload.requestId, payload: rsPayload.objJson)
        }
    }

    private func handle(_ userLogins: [NodeJsUserFunctionsLogin]?, _ ctx: RequestContext) async {
        guard let appUserLogin else {
            return
        }
        if let userLogins {
            for userLoginCall in userLogins {
                let userId: EntityId
                do {
                    userId = try EntityIdImpl(userLoginCall.userId)
                } catch {
                    log.log(.ERROR, "Invalid userId in login call", error)
                    continue
                }
                await appUserLogin.login(
                    userId: userId,
                    loginFinishedFunctionId: userLoginCall.funcId,
                    ctxPayload: userLoginCall.customCtxJson,
                    ctx: ctx
                )
            }
        }
    }

    private func handle(_ userLogouts: [String]?) async {
        guard let userLogin else {
            return
        }
        if let userLogouts {
            for userLogoutCall in userLogouts {
                let userId: EntityId
                do {
                    userId = try EntityIdImpl(userLogoutCall)
                } catch {
                    log.log(.ERROR, "Invalid userId in logout call", error)
                    continue
                }
                await userLogin.logout(userId: userId)
            }
        }
    }

    private func handle(_ userSends: [NodeJsUserFunctionsSend]?) async {
        guard let userSender else {
            return
        }
        if let userSends {
            for userSendCall in userSends {
                let userId: EntityId
                do {
                    userId = try EntityIdImpl(userSendCall.userId)
                } catch {
                    log.log(.ERROR, "Invalid userId in send call", error)
                    continue
                }
                await userSender.send(
                    userId: userId,
                    payload: userSendCall.objJson
                )
            }
        }
    }

    private func handle(
        _ entityFuncInvokes: [NodeJsEntityFunctionsInvoke]?, _ ctx: RequestContext
    ) async {
        guard let appEntities else {
            return
        }
        if let entityFuncInvokes {
            for invoke in entityFuncInvokes {
                let entityId: EntityId
                do {
                    entityId = try EntityIdImpl(invoke.entityId)
                } catch {
                    log.log(
                        .ERROR,
                        "Invalid entityId invoking func=\(invoke._func), type=\(invoke.type)", error
                    )
                    continue
                }
                await appEntities.invoke(
                    params: FunctionParams(
                        theFunc: invoke._func,
                        ctx: ctx,
                        payload: invoke.paramsJson
                    ),
                    entityParams: EntityParams(
                        type: invoke.type,
                        id: entityId
                    )
                )
            }
        }
    }

    private func handle(_ httpClientRequests: [NodeJsHttpClientRequest]?) async {
        guard let httpClient else {
            return
        }
        if let httpClientRequests {
            for httpClientRequest in httpClientRequests {
                await httpClient.request(
                    url: httpClientRequest.url,
                    method: map(httpClientRequest.method),
                    body: httpClientRequest.body,
                    headers: map(httpClientRequest.headers),
                    resultFunc: httpClientRequest.resultFunc,
                    requestCtxJson: httpClientRequest.requestCtxJson
                )
            }
        }
    }

    private func map(_ node: [NodeJsHttpHeader]) -> HttpHeaders {
        var headers: HttpHeaders = [:]

        for elem in node {
            headers[elem.key] = elem.value
        }

        return headers
    }

    private func map(_ node: NodeJsHttpMethod) -> HttpMethod {
        switch node {
        case .GET:
            return .GET
        case .POST:
            return .POST
        case .PUT:
            return .PUT
        case .PATCH:
            return .PATCH
        case .DELETE:
            return .DELETE
        }
    }

    private func handle(_ logs: [NodeJsLoggerLog]?) {
        guard let logger else {
            return
        }
        if let logs {
            for log in logs {
                logger.log(map(log.logLevel), log.message, nil)
            }
        }
    }

    private func map(_ node: NodeJsLogLevel) -> LogLevel {
        switch node {
        case .DEBUG:
            return .DEBUG
        case .ERROR:
            return .ERROR
        case .WARN:
            return .WARN
        case .INFO:
            return .INFO
        }
    }
}
