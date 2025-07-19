struct DeployAppCommandProcessor {
    private let db: AppserverDatabase
    private let jsonEncoder: StringJSONEncoder

    init(
        db: AppserverDatabase,
        jsonEncoder: StringJSONEncoder,
    ) {
        self.db = db
        self.jsonEncoder = jsonEncoder
    }

    func process(request: GammarayProtocolRequest, payload: DeployNodeJsAppCommandRequest) async {
        await db.putApp(appId: payload.appId, app: DatabaseApp(type: .NODEJS, code: payload.code))
        await request.respond(payload: jsonEncoder.encode(DeployNodeJsAppCommandResponse()))
    }
}
