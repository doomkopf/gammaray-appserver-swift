struct NodeJsAppFactory {
    let db: AppserverDatabase
    let config: Config
    let loggerFactory: LoggerFactory
    let globalAppLibComponents: GlobalAppLibComponents
    let nodeProcess: NodeJsAppApi
    let jsonEncoder: StringJSONEncoder

    func create(
        appId: AppId,
        code: String,
    )
        async throws -> App
    {
        let setAppResponse = try await nodeProcess.setApp(
            NodeJsSetAppRequest(id: appId.value, code: code))

        if let setAppError = setAppResponse.error {
            throw AppserverError.NodeJsApp(
                "Error creating nodeJs app - error type: \(setAppError.type), message: \(setAppError.message)"
            )
        }

        let appDef = try await nodeProcess.getAppDefinition(
            NodeJsGetAppDefinitionRequest(appId: appId.value))

        let funcResponseHandler = NodeJsFuncResponseHandlerImpl(loggerFactory: loggerFactory)

        let appEntities = try AppEntities(
            loggerFactory: loggerFactory,
            appId: appId,
            entityTypes: appDef.entity.map { (key, value) in
                try EntityTypeId(key)
            },
            entityFactory: NodeJsEntityFactory(
                loggerFactory: loggerFactory,
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
            appDescription: mapAppDescription(appDef: appDef),
        )
    }

    private func mapAppDescription(appDef: NodeJsGammarayApp) -> AppDescription {
        return AppDescription(
            statelessFuncs: Dictionary(
                uniqueKeysWithValues: appDef.sfunc.map({
                    (key: String, value: NodeJsStatelessFunc) in
                    (
                        try! FunctionName(key),
                        StatelessFuncDescription(visibility: value.vis.toCore())
                    )
                })
            ),
            entityTypes: Dictionary(
                uniqueKeysWithValues: appDef.entity.map({ (key: String, value: NodeJsEntityType) in
                    (
                        try! EntityTypeId(key),
                        EntityTypeDescription(
                            funcs: Dictionary(
                                uniqueKeysWithValues: value.efunc.map({
                                    (key: String, value: NodeJsEntityFunc) in
                                    (
                                        try! FunctionName(key),
                                        EntityFuncDescription(visibility: value.vis.toCore())
                                    )
                                })
                            )
                        )
                    )
                })
            ),
        )
    }
}
