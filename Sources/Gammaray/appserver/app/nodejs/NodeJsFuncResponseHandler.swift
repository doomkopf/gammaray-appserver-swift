protocol NodeJsFuncResponseHandler: Sendable {
    func handle(response: NodeJsFuncResponse, ctx: RequestContext) async
}

struct NodeJsFuncResponseHandlerImpl: NodeJsFuncResponseHandler {
    let lib: Lib

    func handle(response: NodeJsFuncResponse, ctx: RequestContext) {
        handle(response.responseSenderSend)
        handle(response.userFunctionsLogin, ctx)
        handle(response.userFunctionsLogout)
        handle(response.userFunctionsSend)
        handle(response.entityFunctionsInvoke, ctx)
        handle(response.entityQueriesQuery)
        handle(response.httpClientRequest)
        handle(response.listsAdd)
        handle(response.listsClear)
        handle(response.listsIterate)
        handle(response.listsRemove)
        handle(response.loggerLog)
    }

    private func handle(_ rsPayload: NodeJsResponseSenderSend?) {
        if let rsPayload {
            lib.responseSender.send(
                requestId: rsPayload.requestId, obj: rsPayload.objJson)
        }
    }

    private func handle(_ userLogins: [NodeJsUserFunctionsLogin]?, _ ctx: RequestContext) {
        if let userLogins {
            for userLoginCall in userLogins {
                lib.user.login(
                    userId: userLoginCall.userId,
                    loginFinishedFunctionId: userLoginCall.funcId,
                    customCtx: userLoginCall.customCtxJson,
                    ctx: ctx
                )
            }
        }
    }

    private func handle(_ userLogouts: [EntityId]?) {
        if let userLogouts {
            for userLogoutCall in userLogouts {
                lib.user.logout(userId: userLogoutCall)
            }
        }
    }

    private func handle(_ userSends: [NodeJsUserFunctionsSend]?) {
        if let userSends {
            for userSendCall in userSends {
                lib.user.send(
                    userId: userSendCall.userId, obj: userSendCall.objJson)
            }
        }
    }

    private func handle(
        _ entityFuncInvokes: [NodeJsEntityFunctionsInvoke]?, _ ctx: RequestContext
    ) {
        if let entityFuncInvokes {
            for invoke in entityFuncInvokes {
                lib.entityFunc.invoke(
                    entityType: invoke.type,
                    theFunc: invoke._func,
                    entityId: invoke.entityId,
                    params: invoke.paramsJson,
                    ctx: ctx
                )
            }
        }
    }

    private func handle(_ entityQueryInvokes: [NodeJsEntityQueriesQuery]?) {
        if let entityQueryInvokes {
            for invocation in entityQueryInvokes {
                lib.entityQueries.query(
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
                lib.httpClient.request(
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
                lib.lists.add(listId: listAdd.listId, elemToAdd: listAdd.elemToAdd)
            }
        }
    }

    private func handle(_ listClears: [NodeJsListsClear]?) {
        if let listClears {
            for listClear in listClears {
                lib.lists.clear(listId: listClear.listId)
            }
        }
    }

    private func handle(_ listIterates: [NodeJsListsIterate]?) {
        if let listIterates {
            for listIterate in listIterates {
                lib.lists.iterate(
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
                lib.lists.remove(listId: listRemove.listId, elemToRemove: listRemove.elemToRemove)
            }
        }
    }

    private func handle(_ logs: [NodeJsLoggerLog]?) {
        if let logs {
            for log in logs {
                lib.log.log(logLevel: map(log.logLevel), message: log.message)
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
