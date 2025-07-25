final class NodeJsStatelessFunctions: StatelessFunctions {
    private let log: Logger
    private let appId: String
    private let funcResponseHandler: NodeJsFuncResponseHandler
    private let nodeProcess: NodeJsAppApi

    init(
        loggerFactory: LoggerFactory,
        appId: String,
        funcResponseHandler: NodeJsFuncResponseHandler,
        nodeProcess: NodeJsAppApi
    ) {
        log = loggerFactory.createForClass(NodeJsStatelessFunctions.self)

        self.appId = appId
        self.funcResponseHandler = funcResponseHandler
        self.nodeProcess = nodeProcess
    }

    func invoke(_ params: FunctionParams) async {
        do {
            let response = try await nodeProcess.statelessFunc(
                NodeJsFuncRequest(
                    appId: appId,
                    requestId: params.ctx.requestId,
                    requestingUserId: params.ctx.requestingUserId?.value,
                    fun: params.theFunc,
                    paramsJson: params.payload
                ))

            await funcResponseHandler.handle(response: response.general, ctx: params.ctx)
        } catch {
            log.log(.ERROR, "Error executing node func", error)
        }
    }
}
