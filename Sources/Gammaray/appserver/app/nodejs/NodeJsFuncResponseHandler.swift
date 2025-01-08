protocol NodeJsFuncResponseHandler: Sendable {
    func handle(response: NodeJsFuncResponse, ctx: RequestContext) async
}

@available(macOS 10.15, *)
actor NodeJsFuncResponseHandlerImpl: NodeJsFuncResponseHandler {
    private let log: Logger
    private let responseSender: ResponseSender
    private var entityFuncs: EntityFunctions?

    init(
        loggerFactory: LoggerFactory,
        responseSender: ResponseSender
    ) {
        log = loggerFactory.createForClass(NodeJsFuncResponseHandlerImpl.self)

        self.responseSender = responseSender
    }

    func lateBind(entityFuncs: EntityFunctions) {
        self.entityFuncs = entityFuncs
    }

    func handle(response: NodeJsFuncResponse, ctx: RequestContext) async {
        if let rsPayload = response.responseSender {
            responseSender.send(requestId: rsPayload.requestId, objJson: rsPayload.objJson)
        }

        if let entityFuncInvokes = response.entityFuncInvokes {
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
}
