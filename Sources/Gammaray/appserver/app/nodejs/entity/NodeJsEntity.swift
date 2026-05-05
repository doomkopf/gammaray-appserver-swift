private struct FuncCall {
    let fun: String
    let paramsJson: String?
    let ctx: RequestContext
    let callback: @Sendable (_ result: EntityAction) -> Void
}

actor NodeJsEntity: Entity {
    private let log: Logger
    private let appId: AppId
    private let entityId: String
    private let entityType: String
    private let nodeJs: NodeJsAppApi
    private let funcResponseHandler: NodeJsFuncResponseHandler
    private var e: String?

    private var inJsProcessing = false
    private var queuedCalls: [FuncCall] = []

    init(
        loggerFactory: LoggerFactory,
        appId: AppId,
        entityId: String,
        entityType: String,
        nodeJs: NodeJsAppApi,
        funcResponseHandler: NodeJsFuncResponseHandler,
        e: JSON?,
    ) {
        log = loggerFactory.createForClass(NodeJsEntity.self)
        self.appId = appId
        self.entityId = entityId
        self.entityType = entityType
        self.nodeJs = nodeJs
        self.funcResponseHandler = funcResponseHandler
        self.e = e?.buildString()
    }

    func invokeFunction(theFunc: FunctionName, payload: String?, ctx: RequestContext) async
        -> EntityAction
    {
        await withCheckedContinuation { c in
            Task {
                await invokeFunctionCallback(
                    FuncCall(
                        fun: theFunc.value,
                        paramsJson: payload,
                        ctx: ctx,
                        callback: { result in
                            c.resume(returning: result)
                        }
                    ))
            }
        }
    }

    private func invokeFunctionCallback(_ params: FuncCall) async {
        if inJsProcessing {
            queuedCalls.append(params)
        } else {
            inJsProcessing = true

            await nodeCall(params)

            for funcCall in queuedCalls {
                await nodeCall(funcCall)
            }
            queuedCalls = []

            inJsProcessing = false
        }
    }

    private func nodeCall(_ params: FuncCall) async {
        let response: NodeJsEntityFuncResponse
        do {
            response = try await nodeJs.entityFunc(
                NodeJsEntityFuncRequest(
                    funcRequest: NodeJsFuncRequest(
                        appId: appId.value,
                        requestId: params.ctx.requestId,
                        requestingUserId: params.ctx.requestingUserId?.value,
                        clientRequestId: params.ctx.clientRequestId?.value,
                        fun: params.fun,
                        paramsJson: params.paramsJson,
                    ),
                    id: entityId,
                    type: entityType,
                    entityJson: e,
                ))
        } catch {
            params.callback(.none)
            log.log(.ERROR, "Error in nodejs entity func", error)
            return
        }

        if let json = response.entityJson {
            e = json
        }

        Task {
            await funcResponseHandler.handle(response: response.general, ctx: params.ctx)
        }

        params.callback(response.action.toCore())
    }

    func toJSON() -> JSON? {
        guard let e else {
            return nil
        }
        do {
            return try JSON.fromString(e)
        } catch {
            log.log(.ERROR, "Error parsing JSON from string", error)
            return nil
        }
    }
}
