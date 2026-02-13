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
        appId: String,
        statelessFuncs: [String: StatelessFunc],
        entityTypeFuncs: [String: [String: EntityFunc]],
        typeRegistry: NativeTypeRegistry,
    ) async throws -> App {
        let libContainer = LibContainer()

        let appEntities = try AppEntities(
            loggerFactory: loggerFactory,
            appId: appId,
            entityTypes: entityTypeFuncs.keys.sorted(),
            entityFactory: NativeEntityFactory(
                entityTypeFuncs: entityTypeFuncs,
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
            funcs: statelessFuncs,
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
        )
    }
}
