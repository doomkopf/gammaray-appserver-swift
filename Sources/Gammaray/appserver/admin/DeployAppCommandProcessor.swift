struct DeployAppCommandProcessor {
    private let db: AppserverDatabase
    private let jsonEncoder: StringJSONEncoder
    private let pw: String

    init(
        db: AppserverDatabase,
        jsonEncoder: StringJSONEncoder,
        config: Config,
    ) {
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
    }
}
