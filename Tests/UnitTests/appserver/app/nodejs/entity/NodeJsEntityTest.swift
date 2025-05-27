import XCTest

@testable import Gammaray

final class NodeJsEntityTest: XCTestCase {
    func testInvokeFunction() async {
        struct NodeJsAppProcessMock: NodeJsAppApi {
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
                        httpClientRequest: nil,
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
            func setApp(_ request: NodeJsSetAppRequest) async throws
                -> NodeJsSetAppResponse
            {
                throw AppserverError.General("")
            }
            func getAppDefinition(_ request: NodeJsGetAppDefinitionRequest) async throws
                -> NodeJsGammarayApp
            {
                throw AppserverError.General("")
            }
            func shutdown() async {
            }
            func shutdownProcess() {
            }
        }

        actor NodeJsFuncResponseHandlerMock: NodeJsFuncResponseHandler {
            var handlerCalled = false

            func handle(response: Gammaray.NodeJsFuncResponse, ctx: RequestContext) {
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
            payload: nil,
            ctx: EMPTY_REQUEST_CONTEXT
        )

        XCTAssertEqual(EntityAction.none, result)

        let handlerCalled = await funcHandler.handlerCalled
        XCTAssertTrue(handlerCalled)
    }
}
