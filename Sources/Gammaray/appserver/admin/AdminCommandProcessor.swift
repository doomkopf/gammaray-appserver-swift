final class AdminCommandProcessor: Sendable {
    private let log: Logger
    private let jsonDecoder: StringJSONDecoder
    private let jsonEncoder: StringJSONEncoder
    private let deployAppCommandProcessor: DeployAppCommandProcessor

    init(
        loggerFactory: LoggerFactory,
        jsonDecoder: StringJSONDecoder,
        jsonEncoder: StringJSONEncoder,
        deployAppCommandProcessor: DeployAppCommandProcessor,
    ) {
        log = loggerFactory.createForClass(AdminCommandProcessor.self)
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
        self.deployAppCommandProcessor = deployAppCommandProcessor
    }

    func process(request: GammarayProtocolRequest, type: AdminCommandType, payload: String) async {
        switch type {
        case .DEPLOY_NODEJS_APP:
            await processDeployAppCommand(request: request, payload: payload)
        }
    }

    private func processDeployAppCommand(request: GammarayProtocolRequest, payload: String) async {
        do {
            let payload = try jsonDecoder.decode(DeployNodeJsAppCommandRequest.self, payload)
            await deployAppCommandProcessor.process(request: request, payload: payload)
        } catch {
            log.log(.ERROR, "Error decoding deploy-app command", error)
        }
    }
}
