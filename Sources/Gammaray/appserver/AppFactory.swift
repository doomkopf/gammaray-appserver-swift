struct AppFactory {
    private let db: AppserverDatabase
    private let config: Config
    private let loggerFactory: LoggerFactory
    private let globalAppLibComponents: GlobalAppLibComponents
    private let nodeProcess: NodeJsAppApi

    init(
        db: AppserverDatabase,
        config: Config,
        loggerFactory: LoggerFactory,
        globalAppLibComponents: GlobalAppLibComponents,
        nodeProcess: NodeJsAppApi
    ) {
        self.db = db
        self.config = config
        self.loggerFactory = loggerFactory
        self.globalAppLibComponents = globalAppLibComponents
        self.nodeProcess = nodeProcess
    }

    func create(_ id: String) async throws -> App? {
        guard let dbApp = try await db.getApp(id) else {
            return nil
        }

        switch dbApp.type {
        case .NODEJS: return try await createNodeJs(appId: id, code: dbApp.code)
        }
    }

    private func createNodeJs(appId: String, code: String) async throws -> App {
        let setAppResponse = try await nodeProcess.setApp(
            NodeJsSetAppRequest(id: appId, code: code))

        if let setAppError = setAppResponse.error {
            throw AppserverError.NodeJsApp(
                "Error creating nodeJs app - error type: \(setAppError.type), message: \(setAppError.message)"
            )
        }

        let appDef = try await nodeProcess.getAppDefinition(
            NodeJsGetAppDefinitionRequest(appId: appId))

        let funcResponseHandler = NodeJsFuncResponseHandlerImpl(
            loggerFactory: loggerFactory,
            globalAppLibComponents: globalAppLibComponents,
            appLogger: AppLogger(appId: appId, loggerFactory: loggerFactory),
            entityQueries: EntityQueries(),
            lists: Lists()
        )

        let appEntities = try AppEntities(
            appId: appId,
            appDef: map(appDef),
            entityFactory: NodeJsEntityFactory(
                nodeJs: nodeProcess,
                funcResponseHandler: funcResponseHandler
            ),
            db: db,
            config: config
        )

        let entityFunctions = EntityFunctions(
            loggerFactory: loggerFactory,
            appId: appId,
            appEntities: appEntities
        )

        await funcResponseHandler.lateBind(entityFuncs: entityFunctions)

        return App(
            statelessFunctions: NodeJsStatelessFunctions(
                loggerFactory: loggerFactory,
                appId: appId,
                funcResponseHandler: funcResponseHandler,
                nodeProcess: nodeProcess
            ),
            entityFunctions: entityFunctions,
            appEntities: appEntities
        )
    }

    private func map(_ nodeJs: NodeJsGammarayApp) -> GammarayApp {
        GammarayApp(
            sfunc: nodeJs.sfunc.mapValues { nodeJsFunc in
                StatelessFunc(vis: nodeJsFunc.vis.toCore())
            },
            entity: nodeJs.entity.mapValues { nodeJsEntityType in
                EntityType(
                    efunc: nodeJsEntityType.efunc.mapValues { nodeJsEntityFunc in
                        EntityFunc(vis: nodeJsEntityFunc.vis.toCore())
                    }
                )
            }
        )
    }
}
