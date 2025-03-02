import Foundation

struct UserLoginMock: UserLogin {
    func login(userId: EntityId, funcId: String, customCtxJson: String?) async {
    }

    func logout(userId: EntityId) async {
    }
}

struct UserSenderMock: UserSender {
    func send(userId: EntityId, objJson: String) async {
    }
}

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
    let protocolRequestHandler: GammarayProtocolRequestHandler
    let nodeJsAppApi: NodeJsAppApi

    func shutdown() async {
        await nodeJsAppApi.shutdown()
    }
}

func createComponents() async throws -> AppserverComponents {
    let fileReader = ResourceFileReaderImpl(module: Bundle.module)
    let config = try Config(reader: fileReader)
    let loggerFactory = LoggerFactory()
    let jsonEncoder = StringJSONEncoder()
    let jsonDecoder = StringJSONDecoder()
    let responseSender = ResponseSender()
    let scheduler = Scheduler()

    let nodeApi = try NodeJsAppApiImpl(
        loggerFactory: LoggerFactory(),
        config: config,
        scheduler: scheduler
    )
    await nodeApi.start()

    let db = AppserverDatabaseImpl(
        db: InMemoryDatabase(),
        jsonEncoder: jsonEncoder,
        jsonDecoder: jsonDecoder
    )

    let apps = Apps(
        loggerFactory: loggerFactory,
        config: config,
        scheduler: scheduler,
        db: db,
        appFactory: AppFactory(
            db: db,
            config: config,
            loggerFactory: loggerFactory,
            globalAppLibComponents: GlobalAppLibComponents(
                responseSender: responseSender,
                userLogin: UserLoginMock(),
                userSender: UserSenderMock(),
                httpClient: HttpClientMock()
            ),
            nodeProcess: nodeApi
        )
    )

    let protocolRequestHandler = GammarayProtocolRequestHandler(
        loggerFactory: loggerFactory,
        jsonDecoder: jsonDecoder,
        responseSender: responseSender,
        apps: apps
    )

    return AppserverComponents(
        apps: apps,
        fileReader: fileReader,
        config: config,
        protocolRequestHandler: protocolRequestHandler,
        nodeJsAppApi: nodeApi
    )
}
