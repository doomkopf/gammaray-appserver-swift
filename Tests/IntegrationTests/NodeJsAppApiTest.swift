import Foundation
import XCTest

@testable import Gammaray

final class NodeJsAppApiTest: XCTestCase {
    let reader = ResourceFileReaderImpl(module: Bundle.module)

    func testAll() async throws {
        let nodeApi = try await setup()
        defer {
            nodeApi.shutdownProcess()
        }

        try await failWhenSettingInvalidAppCode(nodeApi)
        try await getAppDefinitionReturnsAllDefinitionsFromAppCode(nodeApi)
        try await entityFuncReturnsAllResultingActions(nodeApi)
        try await statelessFuncReturnsAllResultingActions(nodeApi)

        try await nodeApi.shutdown()
    }

    private func setup() async throws -> NodeJsAppApiImpl {
        let scheduler = Scheduler()
        let config = try Config(reader: reader)

        let nodeApi = try NodeJsAppApiImpl(
            config: config,
            scheduler: scheduler
        )
        await nodeApi.start()

        return nodeApi
    }

    private func failWhenSettingInvalidAppCode(_ nodeApi: NodeJsAppApi) async throws {
        let response = try await nodeApi.setApp(
            NodeJsSetAppRequest(id: "test", code: "not js code"))
        XCTAssertEqual(NodeJsSetAppErrorResponseType.SCRIPT_EVALUATION, response.error?.type)
    }

    private func getAppDefinitionReturnsAllDefinitionsFromAppCode(_ nodeApi: NodeJsAppApi)
        async throws
    {
        let code = try reader.readStringFile(name: "NodeJsAppApiTest", ext: "js")
        _ = try await nodeApi.setApp(NodeJsSetAppRequest(id: "test", code: code))

        let appDef = try await nodeApi.getAppDefinition(
            NodeJsGetAppDefinitionRequest(appId: "test"))
        XCTAssertEqual(NodeJsFuncVisibility.PRI, appDef.sfunc["test"]?.vis)
        XCTAssertEqual(NodeJsFuncVisibility.PRI, appDef.entity["person"]?.efunc["test"]?.vis)
    }

    private func entityFuncReturnsAllResultingActions(_ nodeApi: NodeJsAppApi) async throws {
        let entityFuncResponse = try await nodeApi.entityFunc(
            NodeJsEntityFuncRequest(
                appId: "test",
                requestId: "123",
                requestingUserId: nil,
                persistentLocalClientId: nil,
                id: "",
                type: "person",
                efunc: "test",
                entityJson: "{\"name\":\"Timo\"}",
                paramsJson: "{\"moreTest\":\"er\"}"
            )
        )

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
    }

    private func statelessFuncReturnsAllResultingActions(_ nodeApi: NodeJsAppApi) async throws {
        let statelessFuncResponse = try await nodeApi.statelessFunc(
            NodeJsStatelessFuncRequest(
                appId: "test",
                requestId: "123",
                requestingUserId: nil,
                persistentLocalClientId: nil,
                sfunc: "test",
                paramsJson: "{\"text\":\"stuff\"}"
            )
        )

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
    }
}
