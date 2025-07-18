class AdminCommandProcessor {
    private let log: Logger
    private let jsonDecoder: StringJSONDecoder
    private let deployAppCommandProcessor: DeployAppCommandProcessor

    init(
        loggerFactory: LoggerFactory,
        jsonDecoder: StringJSONDecoder,
        deployAppCommandProcessor: DeployAppCommandProcessor,
    ) {
        log = loggerFactory.createForClass(AdminCommandProcessor.self)
        self.jsonDecoder = jsonDecoder
        self.deployAppCommandProcessor = deployAppCommandProcessor
    }

    func process(type: AdminCommandType, payload: String) async {
        switch type {
        case .DEPLOY_NODEJS_APP:
            await processDeployAppCommand(payload: payload)
        }
    }

    private func processDeployAppCommand(payload: String) async {
        do {
            let payload = try jsonDecoder.decode(DeployNodeJsAppCommandPayload.self, payload)
            await deployAppCommandProcessor.process(payload: payload)
        } catch {
            log.log(.ERROR, "Error decoding deploy-app command", error)
        }
    }
}
