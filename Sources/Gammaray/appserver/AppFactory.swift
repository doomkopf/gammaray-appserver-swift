struct AppFactory {
    private let db: AppserverDatabase
    private let config: Config
    private let loggerFactory: LoggerFactory
    private let globalAppLibComponents: GlobalAppLibComponents
    private let nodeProcess: NodeJsAppApi
    private let jsonEncoder: StringJSONEncoder
    private let jsonDecoder: StringJSONDecoder

    init(
        db: AppserverDatabase,
        config: Config,
        loggerFactory: LoggerFactory,
        globalAppLibComponents: GlobalAppLibComponents,
        nodeProcess: NodeJsAppApi,
        jsonEncoder: StringJSONEncoder,
        jsonDecoder: StringJSONDecoder
    ) {
        self.db = db
        self.config = config
        self.loggerFactory = loggerFactory
        self.globalAppLibComponents = globalAppLibComponents
        self.nodeProcess = nodeProcess
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    func create(_ id: String) async throws -> App? {
        guard let dbApp = try await db.getApp(id) else {
            return nil
        }

        switch dbApp.type {
        case .NODEJS:
            return try await createNodeJs(
                appId: id,
                code: dbApp.code
            )
        }
    }

    private func createNodeJs(
        appId: String,
        code: String
    )
        async throws -> App
    {
        let setAppResponse = try await nodeProcess.setApp(
            NodeJsSetAppRequest(id: appId, code: code))

        if let setAppError = setAppResponse.error {
            throw AppserverError.NodeJsApp(
                "Error creating nodeJs app - error type: \(setAppError.type), message: \(setAppError.message)"
            )
        }

        let appDef = try await nodeProcess.getAppDefinition(
            NodeJsGetAppDefinitionRequest(appId: appId))

        let funcResponseHandler = NodeJsFuncResponseHandlerImpl(loggerFactory: loggerFactory)

        let appEntities = try AppEntities(
            loggerFactory: loggerFactory,
            appId: appId,
            entityTypes: appDef.entity.map { (key, value) in
                key
            },
            entityFactory: NodeJsEntityFactory(
                nodeJs: nodeProcess,
                funcResponseHandler: funcResponseHandler
            ),
            db: db,
            config: config
        )

        let statelessFunctions = NodeJsStatelessFunctions(
            loggerFactory: loggerFactory,
            appId: appId,
            funcResponseHandler: funcResponseHandler,
            nodeProcess: nodeProcess
        )

        let appUserLogin = AppUserLogin(
            userLogin: globalAppLibComponents.userLogin,
            statelessFuncs: statelessFunctions,
            jsonEncoder: jsonEncoder
        )

        await funcResponseHandler.lateBind(
            appEntities: appEntities,
            responseSender: globalAppLibComponents.responseSender,
            appUserLogin: appUserLogin,
            userLogin: globalAppLibComponents.userLogin,
            userSender: globalAppLibComponents.userSender,
            httpClient: globalAppLibComponents.httpClient,
            logger: loggerFactory.createLogger("nodeJsApp:\(appId)")
        )

        return App(
            statelessFunctions: statelessFunctions,
            appEntities: appEntities,
        )
    }
}
