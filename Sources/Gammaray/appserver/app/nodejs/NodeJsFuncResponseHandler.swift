protocol NodeJsFuncResponseHandler: Sendable {
    func handle(response: NodeJsFuncResponse, ctx: RequestContext) async
}

struct NodeJsFuncResponseHandlerImpl: NodeJsFuncResponseHandler {
    let responseSender: ResponseSender
    let apiUser: ApiUserFunctionsImpl
    let userLogin: UserLogin
    let userSender: UserSender
    let entityFunc: ApiEntityFunctionsImpl
    let httpClient: ApiHttpClientImpl
    let lists: ApiListsImpl
    let entityQueries: ApiEntityQueriesImpl
    let logger: ApiLoggerImpl

    func handle(response: NodeJsFuncResponse, ctx: RequestContext) async {
        await handle(response.responseSenderSend)
        await handle(response.userFunctionsLogin, ctx)
        await handle(response.userFunctionsLogout)
        await handle(response.userFunctionsSend)
        await handle(response.entityFunctionsInvoke, ctx)
        handle(response.entityQueriesQuery)
        handle(response.httpClientRequest)
        handle(response.listsAdd)
        handle(response.listsClear)
        handle(response.listsIterate)
        handle(response.listsRemove)
        handle(response.loggerLog)
    }

    private func handle(_ rsPayload: NodeJsResponseSenderSend?) async {
        if let rsPayload {
            await responseSender.send(
                requestId: rsPayload.requestId, objJson: rsPayload.objJson)
        }
    }

    private func handle(_ userLogins: [NodeJsUserFunctionsLogin]?, _ ctx: RequestContext) async {
        if let userLogins {
            for userLoginCall in userLogins {
                await apiUser.login(
                    userId: userLoginCall.userId,
                    loginFinishedFunctionId: userLoginCall.funcId,
                    ctxJson: userLoginCall.customCtxJson,
                    ctx: ctx
                )
            }
        }
    }

    private func handle(_ userLogouts: [EntityId]?) async {
        if let userLogouts {
            for userLogoutCall in userLogouts {
                await userLogin.logout(userId: userLogoutCall)
            }
        }
    }

    private func handle(_ userSends: [NodeJsUserFunctionsSend]?) async {
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
        if let entityFuncInvokes {
            for invoke in entityFuncInvokes {
                await entityFunc.invoke(
                    entityType: invoke.type,
                    theFunc: invoke._func,
                    entityId: invoke.entityId,
                    paramsJson: invoke.paramsJson,
                    ctx: ctx
                )
            }
        }
    }

    private func handle(_ entityQueryInvokes: [NodeJsEntityQueriesQuery]?) {
        if let entityQueryInvokes {
            for invocation in entityQueryInvokes {
                entityQueries.query(
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

    private func handle(_ httpClientRequests: [NodeJsHttpClientRequest]?) {
        if let httpClientRequests {
            for httpClientRequest in httpClientRequests {
                httpClient.request(
                    url: httpClientRequest.url,
                    method: map(httpClientRequest.method),
                    body: httpClientRequest.body,
                    headers: map(httpClientRequest.headers),
                    resultFunc: httpClientRequest.resultFunc,
                    requestCtx: httpClientRequest.requestCtxJson
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

    private func handle(_ listAdds: [NodeJsListsAdd]?) {
        if let listAdds {
            for listAdd in listAdds {
                lists.add(listId: listAdd.listId, elemToAdd: listAdd.elemToAdd)
            }
        }
    }

    private func handle(_ listClears: [NodeJsListsClear]?) {
        if let listClears {
            for listClear in listClears {
                lists.clear(listId: listClear.listId)
            }
        }
    }

    private func handle(_ listIterates: [NodeJsListsIterate]?) {
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
        if let listRemoves {
            for listRemove in listRemoves {
                lists.remove(listId: listRemove.listId, elemToRemove: listRemove.elemToRemove)
            }
        }
    }

    private func handle(_ logs: [NodeJsLoggerLog]?) {
        if let logs {
            for log in logs {
                logger.log(logLevel: map(log.logLevel), message: log.message)
            }
        }
    }

    private func map(_ node: NodeJsLogLevel) -> ApiLogLevel {
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
