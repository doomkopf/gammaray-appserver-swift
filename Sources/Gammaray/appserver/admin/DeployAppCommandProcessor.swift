struct DeployAppCommandProcessor {
    private let db: AppserverDatabase

    init(
        db: AppserverDatabase
    ) {
        self.db = db
    }

    func process(payload: DeployNodeJsAppCommandPayload) async {
        await db.putApp(appId: payload.appId, app: DatabaseApp(type: .NODEJS, code: payload.code))
    }
}
