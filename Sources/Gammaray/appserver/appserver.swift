import Foundation

struct HttpClientMock: HttpClient {
    func request(
        url: String,
        method: HttpMethod,
        body: String?,
        headers: HttpHeaders,
        resultFunc: String,
        requestCtxJson: String?
    ) async {
    }
}

struct AppserverComponents {
    let apps: Apps
    let fileReader: ResourceFileReader
    let config: Config
    let db: Database
    let protocolRequestHandler: GammarayProtocolRequestHandler
    let nodeJsAppApi: NodeJsAppApi
    let responseSender: ResponseSender
    let userLogin: UserLogin

    func shutdown() async {
        await apps.shutdown()
        await nodeJsAppApi.shutdown()
        await responseSender.shutdown()
        await userLogin.shutdown()
        await db.shutdown()
    }
}

func createComponents() async throws -> AppserverComponents {
    let fileReader = ResourceFileReaderImpl(module: Bundle.module)
    let config = try Config(reader: fileReader, customConfig: [:])
    let loggerFactory = LoggerFactory()
    let jsonEncoder = StringJSONEncoder()
    let jsonDecoder = StringJSONDecoder()
    let scheduler = SchedulerImpl()
    let responseSender = try ResponseSender(
        loggerFactory: loggerFactory,
        scheduler: scheduler,
    )

    let nodeApi = try NodeJsAppApiImpl(
        loggerFactory: LoggerFactory(),
        config: config,
        scheduler: scheduler
    )
    await nodeApi.start()

    let db = try createDatabase(config: config)
    let appserverDb = AppserverDatabaseImpl(
        db: db,
        jsonEncoder: jsonEncoder,
        jsonDecoder: jsonDecoder
    )

    let userSender = UserSenderImpl(loggerFactory: loggerFactory)
    let userLogin = try UserLogin(userSender: userSender, scheduler: scheduler)

    let apps = Apps(
        loggerFactory: loggerFactory,
        config: config,
        scheduler: scheduler,
        db: appserverDb,
        appFactory: AppFactory(
            db: appserverDb,
            config: config,
            loggerFactory: loggerFactory,
            globalAppLibComponents: GlobalAppLibComponents(
                responseSender: responseSender,
                userLogin: userLogin,
                userSender: userSender,
                httpClient: HttpClientMock()
            ),
            nodeProcess: nodeApi,
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder
        )
    )

    let protocolRequestHandler = GammarayProtocolRequestHandler(
        loggerFactory: loggerFactory,
        jsonEncoder: jsonEncoder,
        jsonDecoder: jsonDecoder,
        responseSender: responseSender,
        apps: apps,
        adminCommandProcessor: AdminCommandProcessor(
            loggerFactory: loggerFactory,
            jsonDecoder: jsonDecoder,
            jsonEncoder: jsonEncoder,
            deployAppCommandProcessor: DeployAppCommandProcessor(
                loggerFactory: loggerFactory,
                db: appserverDb,
                jsonEncoder: jsonEncoder,
                config: config,
            ),
        ),
        userLogin: userLogin,
    )

    return AppserverComponents(
        apps: apps,
        fileReader: fileReader,
        config: config,
        db: db,
        protocolRequestHandler: protocolRequestHandler,
        nodeJsAppApi: nodeApi,
        responseSender: responseSender,
        userLogin: userLogin
    )
}

private func createDatabase(config: Config) throws -> Database {
    let databaseType = config.getString(.databaseType)
    switch databaseType {
    case CONFIG_DATABASETYPE_FILE:
        return FileDatabase(path: config.getString(.fileDatabasePath), ext: "json")
    case CONFIG_DATABASETYPE_INMEMORY:
        return InMemoryDatabase()
    default:
        throw AppserverError.General("Invalid database type: \(databaseType)")
    }
}
