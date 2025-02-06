import XCTest

@testable import Gammaray

/// An ongoing integration test for testing all general use cases on the highest possible level
final class GeneralTest: XCTestCase {
    private let appId = "test"

    actor LastObjResponseSender: ResponseSender {
        private var lastObjJson: String?

        nonisolated func send(requestId: String, objJson: String) {
            Task {
                await setLastObjJson(objJson)
            }
        }

        private func setLastObjJson(_ value: String) {
            lastObjJson = value
        }

        func getLastObjJson() -> String? {
            lastObjJson
        }
    }

    func testGeneral() async throws {
        let reader = ResourceFileReaderImpl(module: Bundle.module)
        let config = try Config(reader: reader)
        let loggerFactory = LoggerFactory()
        let scheduler = Scheduler()
        let responseSender = LastObjResponseSender()

        let db = AppserverDatabaseImpl(
            db: InMemoryDatabase(),
            jsonEncoder: StringJSONEncoder(),
            jsonDecoder: StringJSONDecoder()
        )

        let nodeApi = try NodeJsAppApiImpl(
            loggerFactory: LoggerFactory(),
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
            appFactory: AppFactory(
                db: db,
                config: config,
                loggerFactory: loggerFactory,
                responseSender: responseSender,
                nodeProcess: nodeApi
            )
        )

        let code = try reader.readStringFile(name: "GeneralTest", ext: "js")
        await db.putApp(appId: appId, app: DatabaseApp(type: .NODEJS, code: code))

        await echoFuncResponds(apps: apps, responseSender: responseSender)
        await createPersonEntityAndStoreToDatabase(apps: apps, db: db, config: config)

        await apps.shutdown()
        try await nodeApi.shutdown()
    }

    private func echoFuncResponds(apps: Apps, responseSender: LastObjResponseSender) async {
        let echoParamsJson = "{\"test\":123}"
        await apps.handleFunc(
            appId: appId,
            params: FunctionParams(
                theFunc: "echo",
                ctx: RequestContext(
                    requestId: "id",
                    persistentLocalClientId: nil,
                    requestingUserId: nil
                ),
                paramsJson: echoParamsJson
            ),
            entityParams: nil
        )

        let lastSent = await responseSender.getLastObjJson()
        XCTAssertEqual(echoParamsJson, lastSent)
    }

    private func createPersonEntityAndStoreToDatabase(
        apps: Apps, db: AppserverDatabase, config: Config
    ) async {
        let createPersonParamsJson = "{\"entityName\":\"TestName\"}"
        await apps.handleFunc(
            appId: appId,
            params: FunctionParams(
                theFunc: "createPerson",
                ctx: RequestContext(
                    requestId: "id",
                    persistentLocalClientId: nil,
                    requestingUserId: nil
                ),
                paramsJson: createPersonParamsJson
            ),
            entityParams: EntityParams(
                type: "person",
                id: "theEntityId"
            )
        )

        // sleep twice the amount to be sure the entity was stored
        await gammaraySleep(config.getInt64(.appScheduledTasksIntervalMillis) * 2)

        let dbEntity = await db.getAppEntity(
            appId: appId, entityType: "person", entityId: "theEntityId")

        XCTAssertEqual("{\"name\":\"TestName\"}", dbEntity)
    }
}
