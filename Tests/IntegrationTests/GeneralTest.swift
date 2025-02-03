import XCTest

@testable import Gammaray

/// An ongoing integration test for testing all general use cases on the highest possible level
final class GeneralTest: XCTestCase {
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

        let nodeProc = try NodeJsAppApiImpl(
            config: config,
            scheduler: scheduler
        )
        defer {
            nodeProc.shutdownProcess()
        }
        await nodeProc.start(scheduler: scheduler)

        let appFactory = AppFactory(
            db: db,
            config: config,
            loggerFactory: loggerFactory,
            scheduler: scheduler,
            responseSender: responseSender,
            nodeProcess: nodeProc
        )

        let code = try reader.readStringFile(name: "GeneralTest", ext: "js")
        await db.putApp(appId: "test", app: DatabaseApp(type: .NODEJS, code: code))

        guard let app = try await appFactory.create("test") else {
            XCTFail()
            return
        }

        await echoFuncResponds(app: app, responseSender: responseSender)
        await createPersonEntityAndStoreToDatabase(app: app, db: db, config: config)

        await app.shutdown()
    }

    private func echoFuncResponds(app: App, responseSender: LastObjResponseSender) async {
        let echoParamsJson = "{\"test\":123}"
        await app.handleFunc(
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
        app: App, db: AppserverDatabase, config: Config
    ) async {
        let createPersonParamsJson = "{\"entityName\":\"TestName\"}"
        await app.handleFunc(
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
        await gammaraySleep(config.getInt64(.entityScheduledTasksIntervalMillis) * 2)

        guard
            let dbEntity = await db.getAppEntity(
                appId: "test", entityType: "person", entityId: "theEntityId")
        else {
            XCTFail()
            return
        }

        XCTAssertEqual("{\"name\":\"TestName\"}", dbEntity)
    }
}
