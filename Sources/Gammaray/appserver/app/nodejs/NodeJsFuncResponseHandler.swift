protocol NodeJsFuncResponseHandler: Sendable {
    func handle(response: NodeJsFuncResponse, ctx: RequestContext) async
}

actor NodeJsFuncResponseHandlerImpl: NodeJsFuncResponseHandler {
    private var entityFunc: EntityFunctions?
    private var lists: Lists?
    private var responseSender: ResponseSender?
    private var appUserLogin: AppUserLogin?
    private var userLogin: UserLogin?
    private var userSender: UserSender?
    private var httpClient: HttpClient?
    private var entityQueries: EntityQueries?
    private var logger: Logger?

    func lateBind(
        entityFunc: EntityFunctions,
        lists: Lists,
        responseSender: ResponseSender,
        appUserLogin: AppUserLogin,
        userLogin: UserLogin,
        userSender: UserSender,
        httpClient: HttpClient,
        entityQueries: EntityQueries,
        logger: Logger
    ) {
        self.entityFunc = entityFunc
        self.lists = lists
        self.responseSender = responseSender
        self.appUserLogin = appUserLogin
        self.userLogin = userLogin
        self.userSender = userSender
        self.httpClient = httpClient
        self.entityQueries = entityQueries
        self.logger = logger
    }

    func handle(response: NodeJsFuncResponse, ctx: RequestContext) async {
        await handle(response.responseSenderSend)
        await handle(response.userFunctionsLogin, ctx)
        await handle(response.userFunctionsLogout)
        await handle(response.userFunctionsSend)
        await handle(response.entityFunctionsInvoke, ctx)
        await handle(response.httpClientRequest)
        await handle(response.listsAdd)
        await handle(response.entityQueriesQuery)
        handle(response.listsClear)
        handle(response.listsIterate)
        handle(response.listsRemove)
        handle(response.loggerLog)
    }

    private func handle(_ rsPayload: NodeJsResponseSenderSend?) async {
        guard let responseSender else {
            return
        }
        if let rsPayload {
            await responseSender.send(
                requestId: rsPayload.requestId, objJson: rsPayload.objJson)
        }
    }

    private func handle(_ userLogins: [NodeJsUserFunctionsLogin]?, _ ctx: RequestContext) async {
        guard let appUserLogin else {
            return
        }
        if let userLogins {
            for userLoginCall in userLogins {
                await appUserLogin.login(
                    userId: userLoginCall.userId,
                    loginFinishedFunctionId: userLoginCall.funcId,
                    ctxJson: userLoginCall.customCtxJson,
                    ctx: ctx
                )
            }
        }
    }

    private func handle(_ userLogouts: [EntityId]?) async {
        guard let userLogin else {
            return
        }
        if let userLogouts {
            for userLogoutCall in userLogouts {
                await userLogin.logout(userId: userLogoutCall)
            }
        }
    }

    private func handle(_ userSends: [NodeJsUserFunctionsSend]?) async {
        guard let userSender else {
            return
        }
        if let userSends {
            for userSendCall in userSends {
                await userSender.send(
                    userId: userSendCall.userId, objJson: userSendCall.objJson)
            }
        }
    }

    private func handle(
        _ entityFuncInvokes: [NodeJsEntityFunctionsInvoke]?, _ ctx: RequestContext
    ) async {
        guard let entityFunc else {
            return
        }
        if let entityFuncInvokes {
            for invoke in entityFuncInvokes {
                await entityFunc.invoke(
                    params: FunctionParams(
                        theFunc: invoke._func,
                        ctx: ctx,
                        paramsJson: invoke.paramsJson
                    ),
                    entityParams: EntityParams(
                        type: invoke.type,
                        id: invoke.entityId
                    )
                )
            }
        }
    }

    private func handle(_ entityQueryInvokes: [NodeJsEntityQueriesQuery]?) async {
        guard let entityQueries else {
            return
        }
        if let entityQueryInvokes {
            for invocation in entityQueryInvokes {
                await entityQueries.query(
                    entityType: invocation.entityType,
                    queryFinishedFunctionId: invocation.queryFinishedFunctionId,
                    query: map(invocation.query),
                    customCtx: invocation.customCtxJson
                )
            }
        }
    }

    private func map(_ node: NodeJsEntityQuery) -> EntityQuery {
        EntityQuery(
            attributes: node.attributes.map { nodeAttr in
                EntityQueryAttribute(
                    name: nodeAttr.name,
                    value: EntityQueryAttributeValue(
                        match: nodeAttr.value.match,
                        range: EntityQueryAttributeNumberRange(
                            min: nodeAttr.value.range?.min,
                            max: nodeAttr.value.range?.max
                        )
                    )
                )
            })
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

    private func handle(_ listAdds: [NodeJsListsAdd]?) async {
        guard let lists else {
            return
        }
        if let listAdds {
            for listAdd in listAdds {
                await lists.add(listId: listAdd.listId, elemToAdd: listAdd.elemToAdd)
            }
        }
    }

    private func handle(_ listClears: [NodeJsListsClear]?) {
        guard let lists else {
            return
        }
        if let listClears {
            for listClear in listClears {
                lists.clear(listId: listClear.listId)
            }
        }
    }

    private func handle(_ listIterates: [NodeJsListsIterate]?) {
        guard let lists else {
            return
        }
        if let listIterates {
            for listIterate in listIterates {
                lists.iterate(
                    listId: listIterate.listId,
                    iterationFunctionId: listIterate.iterationFunctionId,
                    iterationFinishedFunctionId: listIterate.iterationFinishedFunctionId,
                    customCtx: listIterate.customCtxJson
                )
            }
        }
    }

    private func handle(_ listRemoves: [NodeJsListsRemove]?) {
        guard let lists else {
            return
        }
        if let listRemoves {
            for listRemove in listRemoves {
                lists.remove(listId: listRemove.listId, elemToRemove: listRemove.elemToRemove)
            }
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
