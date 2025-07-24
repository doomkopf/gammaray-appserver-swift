import XCTest

@testable import Gammaray

/// An ongoing integration test for testing all general use cases on the highest possible level
final class GeneralTest: XCTestCase {
    private let appId = "test"

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

    actor TestRequest: GammarayProtocolRequest {
        var payload = ""
        func respond(payload: String) {
            self.payload = payload
        }
        func cancel() async {
        }
    }

    func testGeneral() async throws {
        let reader = ResourceFileReaderImpl(module: Bundle.module)
        let config = try Config(
            reader: reader,
            customConfig: [:])
        let loggerFactory = LoggerFactory()
        let scheduler = SchedulerImpl()
        let responseSender = try ResponseSender(scheduler: scheduler)
        let jsonEncoder = StringJSONEncoder()
        let jsonDecoder = StringJSONDecoder()

        let db = AppserverDatabaseImpl(
            db: InMemoryDatabase(),
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder
        )

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
                config: config,
                loggerFactory: loggerFactory,
                globalAppLibComponents: GlobalAppLibComponents(
                    responseSender: responseSender,
                    userLogin: try UserLogin(scheduler: scheduler),
                    userSender: UserSenderMock(),
                    httpClient: HttpClientMock()
                ),
                nodeProcess: nodeApi,
                jsonEncoder: jsonEncoder,
                jsonDecoder: jsonDecoder
            )
        )

        let admin = AdminCommandProcessor(
            loggerFactory: loggerFactory,
            jsonDecoder: jsonDecoder,
            jsonEncoder: jsonEncoder,
            deployAppCommandProcessor: DeployAppCommandProcessor(
                db: db, jsonEncoder: jsonEncoder, config: config)
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
        try await userLoginCallsLoginFinishedFunctionWithSessionId(
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
                    requestingUserId: nil
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
        let entityId = try! EntityIdImpl("theEntityId")
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

    private func userLoginCallsLoginFinishedFunctionWithSessionId(
        apps: Apps, responseSender: ResponseSender, jsonDecoder: StringJSONDecoder
    ) async throws {
        let request = TestRequest()
        let requestId = await responseSender.addRequest(request: request)

        await apps.handleFunc(
            appId: appId,
            params: FunctionParams(
                theFunc: "testUserLogin",
                ctx: RequestContext(
                    requestId: requestId,
                    requestingUserId: nil
                ),
                payload: nil
            ),
            entityParams: nil
        )

        let sentPayloadString = await request.payload
        let sentPayload = try jsonDecoder.decode(LoginResult.self, sentPayloadString)
        XCTAssertEqual("1", sentPayload.sessionId)
        XCTAssertEqual("{\"myCustomContext\":\"test\"}", sentPayload.ctxPayload)
    }
}
