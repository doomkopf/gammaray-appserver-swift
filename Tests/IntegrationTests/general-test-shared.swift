import XCTest

@testable import Gammaray

let APP_ID = "test"

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

struct TestComponents {
    let loggerFactory: LoggerFactory
    let config: Config
    let scheduler: Scheduler
    let db: AppserverDatabase
    let responseSender: ResponseSender
    let userSender: UserSender
    let jsonEncoder: StringJSONEncoder
    let jsonDecoder: StringJSONDecoder
    let reader: ResourceFileReader
}

func createTestComponents() async throws -> TestComponents {
    let reader = ResourceFileReaderImpl(module: Bundle.module)
    let config = try Config(
        reader: reader,
        customConfig: [:],
    )
    let loggerFactory = LoggerFactory(logLevel: .ERROR)
    let jsonEncoder = StringJSONEncoder()
    let jsonDecoder = StringJSONDecoder()
    let scheduler = SchedulerImpl()
    let responseSender = try ResponseSender(
        loggerFactory: loggerFactory,
        jsonEncoder: jsonEncoder,
        scheduler: scheduler,
    )

    let db = AppserverDatabaseImpl(
        db: InMemoryDatabase(),
        jsonEncoder: jsonEncoder,
        jsonDecoder: jsonDecoder
    )

    let userSender = UserSenderImpl(loggerFactory: loggerFactory)

    return TestComponents(
        loggerFactory: loggerFactory,
        config: config,
        scheduler: scheduler,
        db: db,
        responseSender: responseSender,
        userSender: userSender,
        jsonEncoder: jsonEncoder,
        jsonDecoder: jsonDecoder,
        reader: reader,
    )
}

/// An ongoing integration test for testing all general use cases on the highest possible level
func generalTests(apps: Apps, components: TestComponents) async throws {
    await echoFuncResponds(apps: apps, responseSender: components.responseSender)
    await createPersonEntityAndStoreToDatabase(
        apps: apps,
        db: components.db,
        config: components.config,
    )
    try await
        userLoginCallsLoginFinishedFunctionWithSessionIdAndSetsUserIdToPersistentSessionAndPushesExtraMessageToUser(
            apps: apps,
            responseSender: components.responseSender,
            jsonDecoder: components.jsonDecoder,
        )
}

func echoFuncResponds(apps: Apps, responseSender: ResponseSender) async {
    let request = TestRequest()
    let requestId = await responseSender.addRequest(request: request)

    let echoParamsJson = "{\"test\":123}"
    await apps.handleFunc(
        appId: APP_ID,
        params: FunctionParams(
            theFunc: "echo",
            ctx: RequestContext(
                requestId: requestId,
                requestingUserId: nil,
                clientRequestId: nil,
                persistentSession: nil,
            ),
            payload: echoParamsJson,
        ),
        entityParams: nil,
    )

    // awaiting to process fire-and-forget tasks
    await gammaraySleep(100)

    let sentPayload = await request.payload
    XCTAssertEqual(echoParamsJson, sentPayload)
}

func createPersonEntityAndStoreToDatabase(
    apps: Apps, db: AppserverDatabase, config: Config
) async {
    let createPersonParamsJson = "{\"entityName\":\"TestName\"}"
    let entityId = try! EntityId("theEntityId")
    await apps.handleFunc(
        appId: APP_ID,
        params: FunctionParams(
            theFunc: "createPerson",
            ctx: EMPTY_REQUEST_CONTEXT,
            payload: createPersonParamsJson
        ),
        entityParams: EntityParams(
            type: "person",
            id: entityId
        ),
    )

    // sleep twice the amount to be sure the entity was stored
    await gammaraySleep(config.getInt64(.appScheduledTasksIntervalMillis) * 2)

    let dbEntity = await db.getAppEntity(
        appId: APP_ID, entityType: "person", entityId: entityId)

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
        appId: APP_ID,
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
