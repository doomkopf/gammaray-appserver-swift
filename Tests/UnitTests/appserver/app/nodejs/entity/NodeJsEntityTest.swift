import XCTest

@testable import Gammaray

final class NodeJsEntityTest: XCTestCase {
    func testInvokeFunction() async {
        final class NodeJsAppProcessMock: NodeJsAppApi {
            func entityFunc(_ request: NodeJsEntityFuncRequest) async throws
                -> NodeJsEntityFuncResponse
            {
                NodeJsEntityFuncResponse(
                    general: NodeJsFuncResponse(
                        responseSenderSend: nil,
                        userFunctionsLogin: nil,
                        userFunctionsLogout: nil,
                        userFunctionsSend: nil,
                        entityFunctionsInvoke: nil,
                        entityQueriesQuery: nil,
                        httpClientRequest: nil,
                        listsAdd: nil,
                        listsClear: nil,
                        listsIterate: nil,
                        listsRemove: nil,
                        loggerLog: nil
                    ),
                    action: NodeJsEntityAction.NONE,
                    entityJson: nil
                )
            }

            // never called
            func statelessFunc(_ request: NodeJsStatelessFuncRequest) async throws
                -> NodeJsStatelessFuncResponse
            {
                throw AppserverError.General("")
            }
            func setApp(_ request: Gammaray.NodeJsSetAppRequest) async throws
                -> Gammaray.NodeJsSetAppResponse
            {
                throw AppserverError.General("")
            }
            func getAppDefinition(_ request: Gammaray.NodeJsGetAppDefinitionRequest) async throws
                -> Gammaray.NodeJsGammarayApp
            {
                throw AppserverError.General("")
            }
            func shutdown() async {
            }
        }

        actor NodeJsFuncResponseHandlerMock: NodeJsFuncResponseHandler {
            var handlerCalled = false

            func handle(response: Gammaray.NodeJsFuncResponse, ctx: Gammaray.RequestContext) {
                handlerCalled = true
            }
        }

        let nodeProc = NodeJsAppProcessMock()
        let funcHandler = NodeJsFuncResponseHandlerMock()

        let subject = NodeJsEntity(
            appId: "",
            entityId: "",
            entityType: "",
            nodeJs: nodeProc,
            funcResponseHandler: funcHandler,
            e: nil
        )

        let result = await subject.invokeFunction(
            theFunc: "",
            paramsJson: nil,
            ctx: EMPTY_REQUEST_CONTEXT
        )

        XCTAssertEqual(EntityAction.none, result.action)

        let handlerCalled = await funcHandler.handlerCalled
        XCTAssertTrue(handlerCalled)
    }
}
