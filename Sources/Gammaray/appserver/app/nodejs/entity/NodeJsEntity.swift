private struct FuncCall {
    let theFunc: String
    let paramsJson: String?
    let ctx: RequestContext
    let callback: @Sendable (_ result: EntityFuncResult) -> Void
}

@available(macOS 10.15, *)
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

    func invokeFunction(theFunc: String, paramsJson: String?, ctx: RequestContext) async
        -> EntityFuncResult
    {
        await withCheckedContinuation { c in
            Task {
                try await invokeFunctionCallback(
                    FuncCall(
                        theFunc: theFunc,
                        paramsJson: paramsJson,
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
                appId: appId,
                requestId: params.ctx.requestId,
                requestingUserId: params.ctx.requestingUserId,
                persistentLocalClientId: params.ctx.persistentLocalClientId,
                id: entityId,
                type: entityType,
                efunc: params.theFunc,
                entityJson: e,
                paramsJson: params.paramsJson
            ))

        if let json = response.entityJson {
            e = json
        }

        await funcResponseHandler.handle(response: response.general, ctx: params.ctx)

        params.callback(EntityFuncResult(action: response.action.toCore()))
    }

    func toString() -> String? {
        e
    }
}
