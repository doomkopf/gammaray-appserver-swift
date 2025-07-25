private struct FuncCall {
    let fun: String
    let paramsJson: String?
    let ctx: RequestContext
    let callback: @Sendable (_ result: EntityAction) -> Void
}

actor NodeJsEntity: Entity {
    private let appId: String
    private let entityId: String
    private let entityType: String
    private let nodeJs: NodeJsAppApi
    private let funcResponseHandler: NodeJsFuncResponseHandler
    private var e: String?

    private var inJsProcessing = false
    private var queuedCalls: [FuncCall] = []

    init(
        appId: String,
        entityId: String,
        entityType: String,
        nodeJs: NodeJsAppApi,
        funcResponseHandler: NodeJsFuncResponseHandler,
        e: String?
    ) {
        self.appId = appId
        self.entityId = entityId
        self.entityType = entityType
        self.nodeJs = nodeJs
        self.funcResponseHandler = funcResponseHandler
        self.e = e
    }

    func invokeFunction(theFunc: String, payload: String?, ctx: RequestContext) async
        -> EntityAction
    {
        await withCheckedContinuation { c in
            Task {
                try await invokeFunctionCallback(
                    FuncCall(
                        fun: theFunc,
                        paramsJson: payload,
                        ctx: ctx,
                        callback: { result in
                            c.resume(returning: result)
                        }
                    ))
            }
        }
    }

    private func invokeFunctionCallback(_ params: FuncCall) async throws {
        if inJsProcessing {
            queuedCalls.append(params)
        } else {
            inJsProcessing = true

            try await nodeCall(params)

            for funcCall in queuedCalls {
                try await nodeCall(funcCall)
            }

            inJsProcessing = false
        }
    }

    private func nodeCall(_ params: FuncCall) async throws {
        let response = try await nodeJs.entityFunc(
            NodeJsEntityFuncRequest(
                funcRequest: NodeJsFuncRequest(
                    appId: appId,
                    requestId: params.ctx.requestId,
                    requestingUserId: params.ctx.requestingUserId?.value,
                    clientRequestId: params.ctx.clientRequestId,
                    fun: params.fun,
                    paramsJson: params.paramsJson,
                ),
                id: entityId,
                type: entityType,
                entityJson: e,
            ))

        if let json = response.entityJson {
            e = json
        }

        await funcResponseHandler.handle(response: response.general, ctx: params.ctx)

        params.callback(response.action.toCore())
    }

    func toString() -> String? {
        e
    }
}
