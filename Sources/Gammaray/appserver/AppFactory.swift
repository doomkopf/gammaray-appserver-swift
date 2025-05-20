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

        let funcResponseHandler = NodeJsFuncResponseHandlerImpl()

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

        let libFactory = LibFactory()

        let lists = try Lists(
            loggerFactory: loggerFactory,
            appId: appId,
            libFactory: libFactory,
            responseSender: globalAppLibComponents.responseSender,
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder,
            db: db,
            config: config
        )

        let appUserLogin = AppUserLogin(
            userLogin: globalAppLibComponents.userLogin,
            statelessFuncs: statelessFunctions,
            jsonEncoder: jsonEncoder
        )

        await funcResponseHandler.lateBind(
            appEntities: appEntities,
            lists: lists,
            responseSender: globalAppLibComponents.responseSender,
            appUserLogin: appUserLogin,
            userLogin: globalAppLibComponents.userLogin,
            userSender: globalAppLibComponents.userSender,
            httpClient: globalAppLibComponents.httpClient,
            entityQueries: EntityQueries(),
            logger: loggerFactory.createLogger("nodeJsApp:\(appId)")
        )
        await libFactory.lateBind(
            responseSender: ApiResponseSenderImpl(
                responseSender: globalAppLibComponents.responseSender
            ),
            user: ApiUserFunctionsImpl(),
            entityFunc: ApiEntityFunctionsImpl(
                appEntities: appEntities,
                jsonEncoder: jsonEncoder
            ),
            httpClient: ApiHttpClientImpl(),
            lists: ApiListsImpl(),
            entityQueries: ApiEntityQueriesImpl(),
            log: ApiLoggerImpl(
                appId: appId,
                loggerFactory: loggerFactory
            )
        )

        return App(
            statelessFunctions: statelessFunctions,
            appEntities: appEntities,
            lists: lists
        )
    }
}
