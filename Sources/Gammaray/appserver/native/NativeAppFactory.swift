struct NativeAppFactory {
    let loggerFactory: LoggerFactory
    let db: AppserverDatabase
    let config: Config
    let responseSender: ResponseSender
    let jsonEncoder: StringJSONEncoder
    let jsonDecoder: StringJSONDecoder
    let scheduler: Scheduler
    let userSender: UserSender

    func create(
        appId: AppId,
        appApi: GammarayApp,
        typeRegistry: NativeTypeRegistry,
    ) async throws -> App {
        let libContainer = LibContainer()

        let appEntities = try AppEntities(
            loggerFactory: loggerFactory,
            appId: appId,
            entityTypes: appApi.entity.keys.shuffled(),
            entityFactory: NativeEntityFactory(
                entityTypes: appApi.entity,
                libContainer: libContainer,
                responseSender: responseSender,
                jsonEncoder: jsonEncoder,
                jsonDecoder: jsonDecoder,
                typeRegistry: typeRegistry,
            ),
            db: db,
            config: config,
        )

        let nativeStatelessFunctions = NativeStatelessFunctions(
            loggerFactory: loggerFactory,
            libContainer: libContainer,
            responseSender: responseSender,
            jsonDecoder: jsonDecoder,
            funcs: appApi.sfunc,
        )

        let userLogin = try UserLogin(
            userSender: userSender,
            scheduler: scheduler,
        )

        let appUserLogin = AppUserLogin(
            userLogin: userLogin,
            statelessFuncs: nativeStatelessFunctions,
            jsonEncoder: jsonEncoder,
        )

        let apiUserFunctions = ApiUserFunctionsImpl(
            jsonEncoder: jsonEncoder,
            userLogin: userLogin,
            appUserLogin: appUserLogin,
            userSender: userSender,
        )

        await libContainer.lateBind(
            lib: Lib(
                responseSender: ApiResponseSenderImpl(responseSender: responseSender),
                user: apiUserFunctions,
                entityFunc: ApiEntityFunctionsImpl(
                    appEntities: appEntities,
                    jsonEncoder: jsonEncoder,
                ),
                httpClient: ApiHttpClientImpl(),
                log: ApiLoggerImpl(
                    appId: appId,
                    loggerFactory: loggerFactory,
                ),
            ),
        )

        return App(
            statelessFunctions: nativeStatelessFunctions,
            appEntities: appEntities,
            appDescription: mapAppDescription(appApi: appApi),
        )
    }

    private func mapAppDescription(appApi: GammarayApp) -> AppDescription {
        return AppDescription(
            statelessFuncs: Dictionary(
                uniqueKeysWithValues: appApi.sfunc.map({
                    (key: FunctionName, value: StatelessFunc) in
                    (key, StatelessFuncDescription(visibility: value.vis))
                })
            ),
            entityTypes: Dictionary(
                uniqueKeysWithValues: appApi.entity.map({ (key: EntityTypeId, value: EntityType) in
                    (
                        key,
                        EntityTypeDescription(
                            funcs: Dictionary(
                                uniqueKeysWithValues: value.efunc.map({
                                    (key: FunctionName, value: EntityFunc) in
                                    (key, EntityFuncDescription(visibility: value.vis))
                                })
                            )
                        )
                    )
                })
            ),
        )
    }
}
