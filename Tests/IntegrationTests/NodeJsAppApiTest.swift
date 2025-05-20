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
    }

    private func setup() async throws -> NodeJsAppApiImpl {
        let scheduler = SchedulerImpl()
        let config = try Config(reader: reader, customConfig: [:])

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
        XCTAssertEqual(generalFuncResponse.responseSenderSend?.requestId, "123")
        XCTAssertEqual(
            generalFuncResponse.responseSenderSend?.objJson,
            "{\"response\":\"\(prefix)someResponse\"}")

        XCTAssertEqual(generalFuncResponse.entityFunctionsInvoke?[0].type, "\(prefix)theType")
        XCTAssertEqual(generalFuncResponse.entityFunctionsInvoke?[0]._func, "theFunc")
        XCTAssertEqual(generalFuncResponse.entityFunctionsInvoke?[0].entityId, "theEntityId")
        XCTAssertEqual(
            generalFuncResponse.entityFunctionsInvoke?[0].paramsJson, "{\"testJson\":123}")

        XCTAssertEqual(generalFuncResponse.entityFunctionsInvoke?[1].type, "\(prefix)theType2")
        XCTAssertEqual(generalFuncResponse.entityFunctionsInvoke?[1]._func, "theFunc2")
        XCTAssertEqual(generalFuncResponse.entityFunctionsInvoke?[1].entityId, "theEntityId2")
        XCTAssertEqual(
            generalFuncResponse.entityFunctionsInvoke?[1].paramsJson, "{\"testJson\":124}")

        XCTAssertEqual(generalFuncResponse.userFunctionsSend?[0].userId, "\(prefix)theUserId")
        XCTAssertEqual(generalFuncResponse.userFunctionsSend?[0].objJson, "{\"testJson\":125}")
        XCTAssertEqual(generalFuncResponse.userFunctionsSend?[1].userId, "\(prefix)theUserId2")
        XCTAssertEqual(generalFuncResponse.userFunctionsSend?[1].objJson, "{\"testJson\":126}")

        XCTAssertEqual(generalFuncResponse.userFunctionsLogin?[0].userId, "\(prefix)theUserId")
        XCTAssertEqual(generalFuncResponse.userFunctionsLogin?[0].funcId, "finishedFunc1")
        XCTAssertEqual(
            generalFuncResponse.userFunctionsLogin?[0].customCtxJson, "{\"testJson\":127}")
        XCTAssertEqual(generalFuncResponse.userFunctionsLogin?[1].userId, "\(prefix)theUserId2")
        XCTAssertEqual(generalFuncResponse.userFunctionsLogin?[1].funcId, "finishedFunc2")
        XCTAssertNil(generalFuncResponse.userFunctionsLogin?[1].customCtxJson)

        XCTAssertEqual(generalFuncResponse.userFunctionsLogout?[0], "\(prefix)theUserId")
        XCTAssertEqual(generalFuncResponse.userFunctionsLogout?[1], "\(prefix)theUserId2")

        XCTAssertEqual(generalFuncResponse.entityQueriesQuery?[0].entityType, "\(prefix)theType")
        XCTAssertEqual(
            generalFuncResponse.entityQueriesQuery?[0].queryFinishedFunctionId, "queryFinishedFunc")
        XCTAssertEqual(
            generalFuncResponse.entityQueriesQuery?[0].query.attributes[0].name, "something")
        XCTAssertEqual(
            generalFuncResponse.entityQueriesQuery?[0].query.attributes[0].value.match, "123")
        XCTAssertEqual(
            generalFuncResponse.entityQueriesQuery?[0].query.attributes[0].value.range?.min, 1)
        XCTAssertEqual(
            generalFuncResponse.entityQueriesQuery?[0].query.attributes[0].value.range?.max, 2)
        XCTAssertNil(generalFuncResponse.entityQueriesQuery?[0].customCtxJson)
        XCTAssertEqual(generalFuncResponse.entityQueriesQuery?[1].entityType, "\(prefix)theType2")
        XCTAssertEqual(
            generalFuncResponse.entityQueriesQuery?[1].queryFinishedFunctionId, "queryFinishedFunc2"
        )
        XCTAssertEqual(generalFuncResponse.entityQueriesQuery?[1].query.attributes.count, 0)
        XCTAssertEqual(
            generalFuncResponse.entityQueriesQuery?[1].customCtxJson, "{\"testJson\":128}")

        XCTAssertEqual(generalFuncResponse.httpClientRequest?[0].url, "\(prefix)theUrl")
        XCTAssertEqual(generalFuncResponse.httpClientRequest?[0].method, .GET)
        XCTAssertEqual(generalFuncResponse.httpClientRequest?[0].body, "theBody")
        XCTAssertEqual(generalFuncResponse.httpClientRequest?[0].headers.count, 1)
        XCTAssertEqual(generalFuncResponse.httpClientRequest?[0].headers[0].key, "headerKey")
        XCTAssertEqual(generalFuncResponse.httpClientRequest?[0].headers[0].value, "headerValue")
        XCTAssertEqual(generalFuncResponse.httpClientRequest?[0].resultFunc, "httpResultFunc")
        XCTAssertEqual(
            generalFuncResponse.httpClientRequest?[0].requestCtxJson, "{\"testJson\":129}")
        XCTAssertEqual(generalFuncResponse.httpClientRequest?[1].url, "\(prefix)theUrl2")
        XCTAssertEqual(generalFuncResponse.httpClientRequest?[1].method, .POST)
        XCTAssertNil(generalFuncResponse.httpClientRequest?[1].body)
        XCTAssertEqual(generalFuncResponse.httpClientRequest?[1].headers.count, 0)
        XCTAssertEqual(generalFuncResponse.httpClientRequest?[1].resultFunc, "httpResultFunc2")
        XCTAssertNil(generalFuncResponse.httpClientRequest?[1].requestCtxJson)

        XCTAssertEqual(generalFuncResponse.listsAdd?[0].listId, "\(prefix)theListId")
        XCTAssertEqual(generalFuncResponse.listsAdd?[0].elemToAdd, "theElem")
        XCTAssertEqual(generalFuncResponse.listsClear?[0].listId, "\(prefix)theListId")
        XCTAssertEqual(generalFuncResponse.listsIterate?[0].listId, "\(prefix)theListId")
        XCTAssertEqual(
            generalFuncResponse.listsIterate?[0].iterationFunctionId, "theIterationFunctionId")
        XCTAssertEqual(
            generalFuncResponse.listsIterate?[0].iterationFinishedFunctionId,
            "theIterationFinishedFunctionId")
        XCTAssertEqual(
            generalFuncResponse.listsIterate?[0].customCtxJson, "{\"testJson\":130}")

        XCTAssertEqual(generalFuncResponse.loggerLog?[0].logLevel, .INFO)
        XCTAssertEqual(generalFuncResponse.loggerLog?[0].message, "this is a log message")
        XCTAssertEqual(generalFuncResponse.loggerLog?[1].logLevel, .ERROR)
        XCTAssertEqual(generalFuncResponse.loggerLog?[1].message, "this is an error message")
    }
}
