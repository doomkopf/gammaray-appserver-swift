protocol NodeJsFuncResponseHandler: Sendable {
    func handle(response: NodeJsFuncResponse, ctx: RequestContext) async
}

@available(macOS 10.15, *)
actor NodeJsFuncResponseHandlerImpl: NodeJsFuncResponseHandler {
    private let log: Logger
    private let globalAppLibComponents: GlobalAppLibComponents
    private let appLogger: AppLogger
    private let entityQueries: EntityQueries
    private let lists: Lists
    private var entityFuncs: EntityFunctions?

    init(
        loggerFactory: LoggerFactory,
        globalAppLibComponents: GlobalAppLibComponents,
        appLogger: AppLogger,
        entityQueries: EntityQueries,
        lists: Lists
    ) {
        log = loggerFactory.createForClass(NodeJsFuncResponseHandlerImpl.self)

        self.globalAppLibComponents = globalAppLibComponents
        self.appLogger = appLogger
        self.entityQueries = entityQueries
        self.lists = lists
    }

    func lateBind(entityFuncs: EntityFunctions) {
        self.entityFuncs = entityFuncs
    }

    func handle(response: NodeJsFuncResponse, ctx: RequestContext) async {
        await handle(response.responseSender)
        await handle(response.userLogins)
        await handle(response.userLogouts)
        await handle(response.userSends)
        await handle(response.entityFuncInvokes, ctx)
        handle(response.entityQueryInvokes)
        await handle(response.httpClientRequests)
        handle(response.listAdds)
        handle(response.listClears)
        handle(response.listIterates)
        handle(response.listRemoves)
        handle(response.logs)
    }

    private func handle(_ rsPayload: NodeJsResponseSenderPayload?) async {
        if let rsPayload = rsPayload {
            await globalAppLibComponents.responseSender.send(
                requestId: rsPayload.requestId, objJson: rsPayload.objJson)
        }
    }

    private func handle(_ userLogins: [NodeJsUserFunctionsLogin]?) async {
        if let userLogins = userLogins {
            for userLoginCall in userLogins {
                await globalAppLibComponents.userLogin.login(
                    userId: userLoginCall.userId,
                    funcId: userLoginCall.funcId,
                    customCtxJson: userLoginCall.customCtxJson
                )
            }
        }
    }

    private func handle(_ userLogouts: [EntityId]?) async {
        if let userLogouts = userLogouts {
            for userLogoutCall in userLogouts {
                await globalAppLibComponents.userLogin.logout(userId: userLogoutCall)
            }
        }
    }

    private func handle(_ userSends: [NodeJsUserFunctionsSendPayload]?) async {
        if let userSends = userSends {
            for userSendCall in userSends {
                await globalAppLibComponents.userSender.send(
                    userId: userSendCall.userId, objJson: userSendCall.objJson)
            }
        }
    }

    private func handle(
        _ entityFuncInvokes: [NodeJsEntityFuncInvokePayload]?, _ ctx: RequestContext
    ) async {
        if let entityFuncInvokes = entityFuncInvokes {
            for invoke in entityFuncInvokes {
                guard let funcs = entityFuncs else {
                    log.log(LogLevel.ERROR, "Not fully initialized yet", nil)
                    return
                }

                await funcs.invoke(
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

    private func handle(_ entityQueryInvokes: [NodeJsEntityQueryInvokePayload]?) {
        if let entityQueryInvokes = entityQueryInvokes {
            for invocation in entityQueryInvokes {
                entityQueries.query(
                    entityType: invocation.entityType,
                    queryFinishedFunctionId: invocation.queryFinishedFunctionId,
                    query: map(invocation.query),
                    customCtxJson: invocation.customCtxJson
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
        if let httpClientRequests = httpClientRequests {
            for httpClientRequest in httpClientRequests {
                await globalAppLibComponents.httpClient.request(
                    url: httpClientRequest.url,
                    method: map(httpClientRequest.method),
                    body: httpClientRequest.body,
                    headers: httpClientRequest.headers.map { nodeHeader in
                        HttpHeader(key: nodeHeader.key, value: nodeHeader.value)
                    },
                    resultFunc: httpClientRequest.resultFunc,
                    requestCtxJson: httpClientRequest.requestCtxJson
                )
            }
        }
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

    private func handle(_ listAdds: [NodeJsListAdd]?) {
        if let listAdds = listAdds {
            for listAdd in listAdds {
                lists.add(listId: listAdd.listId, elemToAdd: listAdd.elemToAdd)
            }
        }
    }

    private func handle(_ listClears: [NodeJsListClear]?) {
        if let listClears = listClears {
            for listClear in listClears {
                lists.clear(listId: listClear.listId)
            }
        }
    }

    private func handle(_ listIterates: [NodeJsListIterate]?) {
        if let listIterates = listIterates {
            for listIterate in listIterates {
                lists.iterate(
                    listId: listIterate.listId,
                    iterationFunctionId: listIterate.iterationFunctionId,
                    iterationFinishedFunctionId: listIterate.iterationFinishedFunctionId,
                    customCtxJson: listIterate.customCtxJson
                )
            }
        }
    }

    private func handle(_ listRemoves: [NodeJsListRemove]?) {
        if let listRemoves = listRemoves {
            for listRemove in listRemoves {
                lists.remove(listId: listRemove.listId, elemToRemove: listRemove.elemToRemove)
            }
        }
    }

    private func handle(_ logs: [NodeJsLog]?) {
        if let logs = logs {
            for log in logs {
                appLogger.log(
                    logLevel: map(log.logLevel),
                    message: log.message
                )
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
