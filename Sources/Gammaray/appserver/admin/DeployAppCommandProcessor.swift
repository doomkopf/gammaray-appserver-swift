final class DeployAppCommandProcessor: Sendable {
    private let log: Logger
    private let jsonEncoder: StringJSONEncoder
    private let apps: Apps
    private let pw: String

    init(
        loggerFactory: LoggerFactory,
        jsonEncoder: StringJSONEncoder,
        apps: Apps,
        config: Config,
    ) {
        log = loggerFactory.createForClass(DeployAppCommandProcessor.self)
        self.jsonEncoder = jsonEncoder
        self.apps = apps

        pw = config.getString(.appDeploymentPassword)
    }

    func process(request: GammarayProtocolRequest, payload: DeployNodeJsAppCommandRequest) async {
        if payload.pw != pw {
            await request.respond(
                payload: jsonEncoder.encode(
                    DeployNodeJsAppCommandResponse(errorMsg: "Invalid password")))
            return
        }

        await apps.deployNodeJsApp(appId: payload.appId, code: payload.script)

        await request.respond(
            payload: jsonEncoder.encode(DeployNodeJsAppCommandResponse(errorMsg: nil)))

        log.log(.INFO, "Deployed app: \(payload.appId)", nil)
    }
}
