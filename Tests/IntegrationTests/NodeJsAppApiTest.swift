import Foundation
import XCTest

@testable import Gammaray

final class NodeJsAppApiTest: XCTestCase {
    func testCom() async throws {
        let scheduler = Scheduler()

        let reader = ResourceFileReaderImpl(module: Bundle.module)

        let config = try Config(reader: reader)

        let nodeProc = try NodeJsAppApiImpl(
            config: config,
            scheduler: scheduler
        )
        defer {
            nodeProc.shutdownProcess()
        }
        await nodeProc.start(scheduler: scheduler)

        let response = try await nodeProc.setApp(
            NodeJsSetAppRequest(id: "test", code: "not js code"))
        XCTAssertEqual(NodeJsSetAppErrorResponseType.SCRIPT_EVALUATION, response.error?.type)

        let code = try reader.readStringFile(name: "NodeJsAppApiTest", ext: "js")

        _ = try await nodeProc.setApp(NodeJsSetAppRequest(id: "test", code: code))

        let appDef = try await nodeProc.getAppDefinition(
            NodeJsGetAppDefinitionRequest(appId: "test"))
        XCTAssertEqual(NodeJsFuncVisibility.PRI, appDef.sfunc["test"]?.vis)
        XCTAssertEqual(NodeJsFuncVisibility.PRI, appDef.entity["person"]?.efunc["test"]?.vis)

        let entityFuncResponse = try await nodeProc.entityFunc(
            NodeJsEntityFuncRequest(
                appId: "test",
                requestId: "123",
                requestingUserId: nil,
                persistentLocalClientId: nil,
                id: "",
                type: "person",
                efunc: "test",
                entityJson: "{\"name\":\"Timo\"}",
                paramsJson: "{\"moreTest\":\"er\"}"))

        XCTAssertEqual(NodeJsEntityAction.SET_ENTITY, entityFuncResponse.action)

        XCTAssertEqual(entityFuncResponse.entityJson, "{\"name\":\"Timoer\"}")

        XCTAssertEqual(entityFuncResponse.general.responseSender?.requestId, "123")
        XCTAssertEqual(
            entityFuncResponse.general.responseSender?.objJson, "{\"response\":\"someResponse\"}")

        XCTAssertEqual(entityFuncResponse.general.entityFuncInvokes?[0].type, "theType")
        XCTAssertEqual(entityFuncResponse.general.entityFuncInvokes?[0]._func, "theFunc")
        XCTAssertEqual(entityFuncResponse.general.entityFuncInvokes?[0].entityId, "theEntityId")
        XCTAssertEqual(
            entityFuncResponse.general.entityFuncInvokes?[0].paramsJson, "{\"testJson\":123}")

        XCTAssertEqual(entityFuncResponse.general.entityFuncInvokes?[1].type, "theType2")
        XCTAssertEqual(entityFuncResponse.general.entityFuncInvokes?[1]._func, "theFunc2")
        XCTAssertEqual(entityFuncResponse.general.entityFuncInvokes?[1].entityId, "theEntityId2")
        XCTAssertEqual(
            entityFuncResponse.general.entityFuncInvokes?[1].paramsJson, "{\"testJson\":124}")

        let statelessFuncResponse = try await nodeProc.statelessFunc(
            NodeJsStatelessFuncRequest(
                appId: "test",
                requestId: "123",
                requestingUserId: nil,
                persistentLocalClientId: nil,
                sfunc: "test",
                paramsJson: "{\"text\":\"stuff\"}"))

        XCTAssertEqual(statelessFuncResponse.general.responseSender?.requestId, "123")
        XCTAssertEqual(
            statelessFuncResponse.general.responseSender?.objJson,
            "{\"response\":\"statelessFuncResponsestuff\"}")

        XCTAssertEqual(
            statelessFuncResponse.general.entityFuncInvokes?[0].type, "theTypeStatelessFunc")
        XCTAssertEqual(
            statelessFuncResponse.general.entityFuncInvokes?[0]._func, "theFuncStatelessFunc")
        XCTAssertEqual(
            statelessFuncResponse.general.entityFuncInvokes?[0].entityId, "theEntityIdStatelessFunc"
        )
        XCTAssertEqual(
            statelessFuncResponse.general.entityFuncInvokes?[0].paramsJson, "{\"testJson\":123}")

        XCTAssertEqual(
            statelessFuncResponse.general.entityFuncInvokes?[1].type, "theType2StatelessFunc")
        XCTAssertEqual(
            statelessFuncResponse.general.entityFuncInvokes?[1]._func, "theFunc2StatelessFunc")
        XCTAssertEqual(
            statelessFuncResponse.general.entityFuncInvokes?[1].entityId,
            "theEntityId2StatelessFunc")
        XCTAssertEqual(
            statelessFuncResponse.general.entityFuncInvokes?[1].paramsJson, "{\"testJson\":124}")

        try await nodeProc.shutdown()
    }
}
