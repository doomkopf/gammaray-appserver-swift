struct NativeAppFactory {
    let loggerFactory: LoggerFactory
    let db: AppserverDatabase
    let config: Config
    let responseSender: ResponseSender
    let jsonEncoder: StringJSONEncoder
    let jsonDecoder: StringJSONDecoder

    func create(
        appId: String,
        statelessFuncs: [String: StatelessFunc],
        entityTypeFuncs: [String: [String: EntityFunc]],
        typeRegistry: NativeTypeRegistry,
    ) async throws -> App {
        let libFactory = LibFactory()

        let appEntities = try AppEntities(
            loggerFactory: loggerFactory,
            appId: appId,
            entityTypes: entityTypeFuncs.keys.sorted(),
            entityFactory: NativeEntityFactory(
                entityTypeFuncs: entityTypeFuncs,
                libFactory: libFactory,
                responseSender: responseSender,
                jsonEncoder: jsonEncoder,
                jsonDecoder: jsonDecoder,
                typeRegistry: typeRegistry,
            ),
            db: db,
            config: config,
        )

        await libFactory.lateBind(
            responseSender: ApiResponseSenderImpl(responseSender: responseSender),
            user: ApiUserFunctionsImpl(),
            entityFunc: ApiEntityFunctionsImpl(
                appEntities: appEntities,
                jsonEncoder: jsonEncoder,
            ),
            httpClient: ApiHttpClientImpl(),
            log: ApiLoggerImpl(
                appId: appId,
                loggerFactory: loggerFactory,
            ),
        )

        return App(
            statelessFunctions: NativeStatelessFunctions(
                loggerFactory: loggerFactory,
                lib: try await libFactory.create(),
                responseSender: responseSender,
                jsonDecoder: jsonDecoder,
                funcs: statelessFuncs,
            ),
            appEntities: appEntities,
        )
    }
}
