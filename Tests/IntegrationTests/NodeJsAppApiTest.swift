import Foundation
import XCTest

@testable import Gammaray

final class NodeJsAppApiTest: XCTestCase {
    private let appId = "test"

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
            loggerFactory: LoggerFactory(),
            config: config,
            scheduler: scheduler
        )
        await nodeApi.start()

        return nodeApi
    }

    private func failWhenSettingInvalidAppCode(_ nodeApi: NodeJsAppApi) async throws {
        let response = try await nodeApi.setApp(
            NodeJsSetAppRequest(id: appId, code: "not js code"))
        XCTAssertEqual(NodeJsSetAppErrorResponseType.SCRIPT_EVALUATION, response.error?.type)
    }

    private func getAppDefinitionReturnsAllDefinitionsFromAppCode(_ nodeApi: NodeJsAppApi)
        async throws
    {
        let code = try reader.readStringFile(name: "NodeJsAppApiTest", ext: "js")
        _ = try await nodeApi.setApp(NodeJsSetAppRequest(id: appId, code: code))

        let appDef = try await nodeApi.getAppDefinition(
            NodeJsGetAppDefinitionRequest(appId: appId))
        XCTAssertEqual(NodeJsFuncVisibility.PRI, appDef.sfunc["test"]?.vis)
        XCTAssertEqual(NodeJsFuncVisibility.PRI, appDef.entity["person"]?.efunc["test"]?.vis)
    }

    private func entityFuncReturnsAllResultingActions(_ nodeApi: NodeJsAppApi) async throws {
        let entityFuncResponse = try await nodeApi.entityFunc(
            NodeJsEntityFuncRequest(
                appId: appId,
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

        verifyFuncReturnsAllGeneralResultingActions(
            generalFuncResponse: entityFuncResponse.general,
            prefix: "entity"
        )
    }

    private func statelessFuncReturnsAllResultingActions(_ nodeApi: NodeJsAppApi) async throws {
        let statelessFuncResponse = try await nodeApi.statelessFunc(
            NodeJsStatelessFuncRequest(
                appId: appId,
                requestId: "123",
                requestingUserId: nil,
                persistentLocalClientId: nil,
                sfunc: "test",
                paramsJson: "{\"text\":\"stuff\"}"
            )
        )

        verifyFuncReturnsAllGeneralResultingActions(
            generalFuncResponse: statelessFuncResponse.general,
            prefix: "stateless"
        )
    }

    private func verifyFuncReturnsAllGeneralResultingActions(
        generalFuncResponse: NodeJsFuncResponse,
        prefix: String
    ) {
        XCTAssertEqual(generalFuncResponse.responseSender?.requestId, "123")
        XCTAssertEqual(
            generalFuncResponse.responseSender?.objJson, "{\"response\":\"\(prefix)someResponse\"}")

        XCTAssertEqual(generalFuncResponse.entityFuncInvokes?[0].type, "\(prefix)theType")
        XCTAssertEqual(generalFuncResponse.entityFuncInvokes?[0]._func, "theFunc")
        XCTAssertEqual(generalFuncResponse.entityFuncInvokes?[0].entityId, "theEntityId")
        XCTAssertEqual(generalFuncResponse.entityFuncInvokes?[0].paramsJson, "{\"testJson\":123}")

        XCTAssertEqual(generalFuncResponse.entityFuncInvokes?[1].type, "\(prefix)theType2")
        XCTAssertEqual(generalFuncResponse.entityFuncInvokes?[1]._func, "theFunc2")
        XCTAssertEqual(generalFuncResponse.entityFuncInvokes?[1].entityId, "theEntityId2")
        XCTAssertEqual(generalFuncResponse.entityFuncInvokes?[1].paramsJson, "{\"testJson\":124}")

        XCTAssertEqual(generalFuncResponse.userSends?[0].userId, "\(prefix)theUserId")
        XCTAssertEqual(generalFuncResponse.userSends?[0].objJson, "{\"testJson\":125}")
        XCTAssertEqual(generalFuncResponse.userSends?[1].userId, "\(prefix)theUserId2")
        XCTAssertEqual(generalFuncResponse.userSends?[1].objJson, "{\"testJson\":126}")

        XCTAssertEqual(generalFuncResponse.userLogins?[0].userId, "\(prefix)theUserId")
        XCTAssertEqual(generalFuncResponse.userLogins?[0].funcId, "finishedFunc1")
        XCTAssertEqual(generalFuncResponse.userLogins?[0].customCtxJson, "{\"testJson\":127}")
        XCTAssertEqual(generalFuncResponse.userLogins?[1].userId, "\(prefix)theUserId2")
        XCTAssertEqual(generalFuncResponse.userLogins?[1].funcId, "finishedFunc2")
        XCTAssertNil(generalFuncResponse.userLogins?[1].customCtxJson)

        XCTAssertEqual(generalFuncResponse.userLogouts?[0], "\(prefix)theUserId")
        XCTAssertEqual(generalFuncResponse.userLogouts?[1], "\(prefix)theUserId2")

        XCTAssertEqual(generalFuncResponse.entityQueryInvokes?[0].entityType, "\(prefix)theType")
        XCTAssertEqual(
            generalFuncResponse.entityQueryInvokes?[0].queryFinishedFunctionId, "queryFinishedFunc")
        XCTAssertEqual(generalFuncResponse.entityQueryInvokes?[0].query.attributes.count, 0)
        XCTAssertNil(generalFuncResponse.entityQueryInvokes?[0].customCtxJson)
        XCTAssertEqual(generalFuncResponse.entityQueryInvokes?[1].entityType, "\(prefix)theType2")
        XCTAssertEqual(
            generalFuncResponse.entityQueryInvokes?[1].queryFinishedFunctionId, "queryFinishedFunc2"
        )
        XCTAssertEqual(generalFuncResponse.entityQueryInvokes?[1].query.attributes.count, 0)
        XCTAssertEqual(
            generalFuncResponse.entityQueryInvokes?[1].customCtxJson, "{\"testJson\":128}")
    }
}
