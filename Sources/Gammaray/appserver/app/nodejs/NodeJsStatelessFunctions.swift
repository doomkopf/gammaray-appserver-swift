@available(macOS 10.15, *)
class NodeJsStatelessFunctions: StatelessFunctions {
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
                NodeJsStatelessFuncRequest(
                    appId: appId,
                    requestId: params.ctx.requestId,
                    requestingUserId: params.ctx.requestingUserId,
                    persistentLocalClientId: params.ctx.persistentLocalClientId,
                    sfunc: params.theFunc,
                    paramsJson: params.paramsJson
                ))

            await funcResponseHandler.handle(response: response.general, ctx: params.ctx)
        } catch {
            log.log(LogLevel.ERROR, "Error executing node func", error)
        }
    }
}
