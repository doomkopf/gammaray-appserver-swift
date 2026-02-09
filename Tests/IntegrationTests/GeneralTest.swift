import XCTest

@testable import Gammaray

/// An ongoing integration test for testing all general use cases on the highest possible level
final class GeneralTest: XCTestCase {
    private let appId = "test"

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

    actor TestRequest: GammarayProtocolRequest {
        var payload = ""
        func respond(payload: String) {
            self.payload = payload
        }
        func cancel() async {
        }
    }

    actor GammarayPersistentSessionMock: GammarayPersistentSession {
        var userId: EntityId?
        var payload = ""
        func send(payload: String) {
            self.payload = payload
        }
        func assignUserId(userId: EntityId) {
            self.userId = userId
        }
        func getUserId() -> EntityId? {
            nil
        }
    }

    func testGeneral() async throws {
        let reader = ResourceFileReaderImpl(module: Bundle.module)
        let config = try Config(
            reader: reader,
            customConfig: [:])
        let loggerFactory = LoggerFactory(logLevel: .ERROR)
        let scheduler = SchedulerImpl()
        let responseSender = try ResponseSender(
            loggerFactory: loggerFactory,
            scheduler: scheduler,
        )
        let jsonEncoder = StringJSONEncoder()
        let jsonDecoder = StringJSONDecoder()

        let db = AppserverDatabaseImpl(
            db: InMemoryDatabase(),
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder
        )

        let userSender = UserSenderImpl(loggerFactory: loggerFactory)

        let nodeApi = try NodeJsAppApiImpl(
            loggerFactory: loggerFactory,
            config: config,
            scheduler: scheduler
        )
        defer {
            nodeApi.shutdownProcess()
        }
        await nodeApi.start()

        let apps = Apps(
            loggerFactory: loggerFactory,
            config: config,
            scheduler: scheduler,
            db: db,
            appFactory: AppFactory(
                db: db,
                nodeJsAppFactory: NodeJsAppFactory(
                    db: db,
                    config: config,
                    loggerFactory: loggerFactory,
                    globalAppLibComponents: GlobalAppLibComponents(
                        responseSender: responseSender,
                        userLogin: try UserLogin(userSender: userSender, scheduler: scheduler),
                        userSender: userSender,
                        httpClient: HttpClientMock()
                    ),
                    nodeProcess: nodeApi,
                    jsonEncoder: jsonEncoder,
                ),
            ),
            staticApps: [:],
        )

        let admin = AdminCommandProcessor(
            loggerFactory: loggerFactory,
            jsonDecoder: jsonDecoder,
            jsonEncoder: jsonEncoder,
            deployAppCommandProcessor: DeployAppCommandProcessor(
                loggerFactory: loggerFactory,
                jsonEncoder: jsonEncoder,
                apps: apps,
                config: config,
            )
        )

        let code = try reader.readStringFile(name: "GeneralTest", ext: "js")
        await admin.process(
            request: NoopGammarayProtocolRequest(),
            type: .DEPLOY_NODEJS_APP,
            payload: jsonEncoder.encode(
                DeployNodeJsAppCommandRequest(
                    appId: appId, pw: "thisdefaultpasswordshouldnotbeused", script: code)))

        await echoFuncResponds(apps: apps, responseSender: responseSender)
        await createPersonEntityAndStoreToDatabase(apps: apps, db: db, config: config)
        try await
            userLoginCallsLoginFinishedFunctionWithSessionIdAndSetsUserIdToPersistentSessionAndPushesExtraMessageToUser(
                apps: apps, responseSender: responseSender, jsonDecoder: jsonDecoder)
    }

    private func echoFuncResponds(apps: Apps, responseSender: ResponseSender) async {
        let request = TestRequest()
        let requestId = await responseSender.addRequest(request: request)

        let echoParamsJson = "{\"test\":123}"
        await apps.handleFunc(
            appId: appId,
            params: FunctionParams(
                theFunc: "echo",
                ctx: RequestContext(
                    requestId: requestId,
                    requestingUserId: nil,
                    clientRequestId: nil,
                    persistentSession: nil,
                ),
                payload: echoParamsJson
            ),
            entityParams: nil
        )

        let sentPayload = await request.payload
        XCTAssertEqual(echoParamsJson, sentPayload)
    }

    private func createPersonEntityAndStoreToDatabase(
        apps: Apps, db: AppserverDatabase, config: Config
    ) async {
        let createPersonParamsJson = "{\"entityName\":\"TestName\"}"
        let entityId = try! EntityId("theEntityId")
        await apps.handleFunc(
            appId: appId,
            params: FunctionParams(
                theFunc: "createPerson",
                ctx: EMPTY_REQUEST_CONTEXT,
                payload: createPersonParamsJson
            ),
            entityParams: EntityParams(
                type: "person",
                id: entityId
            )
        )

        // sleep twice the amount to be sure the entity was stored
        await gammaraySleep(config.getInt64(.appScheduledTasksIntervalMillis) * 2)

        let dbEntity = await db.getAppEntity(
            appId: appId, entityType: "person", entityId: entityId)

        XCTAssertEqual("{\"name\":\"TestName\"}", dbEntity)
    }

    private func
        userLoginCallsLoginFinishedFunctionWithSessionIdAndSetsUserIdToPersistentSessionAndPushesExtraMessageToUser(
            apps: Apps, responseSender: ResponseSender, jsonDecoder: StringJSONDecoder
        ) async throws
    {
        let request = TestRequest()
        let requestId = await responseSender.addRequest(request: request)
        let persistentSession = GammarayPersistentSessionMock()

        await apps.handleFunc(
            appId: appId,
            params: FunctionParams(
                theFunc: "testUserLogin",
                ctx: RequestContext(
                    requestId: requestId,
                    requestingUserId: nil,
                    clientRequestId: nil,
                    persistentSession: persistentSession,
                ),
                payload: nil,
            ),
            entityParams: nil,
        )

        let sentPayloadString = await request.payload
        let sentPayload = try jsonDecoder.decode(LoginResult.self, sentPayloadString)
        XCTAssertEqual("1", sentPayload.sessionId)
        XCTAssertEqual("{\"myCustomContext\":\"test\"}", sentPayload.ctxPayload)

        let setUserId = await persistentSession.userId
        let pushedPayload = await persistentSession.payload
        XCTAssertEqual("myUserId", setUserId?.value)
        XCTAssertEqual("{\"msg\":\"pushed message\"}", pushedPayload)
    }
}
