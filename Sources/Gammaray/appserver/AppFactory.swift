struct AppFactory {
    private let db: AppserverDatabase
    private let nodeJsAppFactory: NodeJsAppFactory

    init(
        db: AppserverDatabase,
        nodeJsAppFactory: NodeJsAppFactory,
    ) {
        self.db = db
        self.nodeJsAppFactory = nodeJsAppFactory
    }

    func create(_ id: String) async throws -> App? {
        guard let dbApp = try await db.getApp(id) else {
            return nil
        }

        switch dbApp.type {
        case .NODEJS:
            return try await nodeJsAppFactory.create(
                appId: id,
                code: dbApp.code
            )
        }
    }
}
