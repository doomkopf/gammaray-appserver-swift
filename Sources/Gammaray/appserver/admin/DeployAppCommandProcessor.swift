final class DeployAppCommandProcessor: Sendable {
    private let log: Logger
    private let db: AppserverDatabase
    private let jsonEncoder: StringJSONEncoder
    private let pw: String

    init(
        loggerFactory: LoggerFactory,
        db: AppserverDatabase,
        jsonEncoder: StringJSONEncoder,
        config: Config,
    ) {
        log = loggerFactory.createForClass(DeployAppCommandProcessor.self)
        self.db = db
        self.jsonEncoder = jsonEncoder

        pw = config.getString(.appDeploymentPassword)
    }

    func process(request: GammarayProtocolRequest, payload: DeployNodeJsAppCommandRequest) async {
        if payload.pw != pw {
            await request.respond(
                payload: jsonEncoder.encode(
                    DeployNodeJsAppCommandResponse(errorMsg: "Invalid password")))
            return
        }

        await db.putApp(appId: payload.appId, app: DatabaseApp(type: .NODEJS, code: payload.script))
        await request.respond(
            payload: jsonEncoder.encode(DeployNodeJsAppCommandResponse(errorMsg: nil)))

        log.log(.INFO, "Deployed app: \(payload.appId)", nil)
    }
}
