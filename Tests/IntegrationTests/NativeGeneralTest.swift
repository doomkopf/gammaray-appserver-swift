import XCTest

@testable import Gammaray

final class NativeGeneralTest: XCTestCase {
    struct NoopNodeJsAppApi: NodeJsAppApi {
        func setApp(_ request: NodeJsSetAppRequest) async throws -> NodeJsSetAppResponse {
            throw AppserverError.NodeJsApp("not implemented")
        }
        func getAppDefinition(_ request: NodeJsGetAppDefinitionRequest) async throws
            -> NodeJsGammarayApp
        {
            throw AppserverError.NodeJsApp("not implemented")
        }
        func entityFunc(_ request: NodeJsEntityFuncRequest) async throws -> NodeJsEntityFuncResponse
        {
            throw AppserverError.NodeJsApp("not implemented")
        }
        func statelessFunc(_ request: NodeJsFuncRequest) async throws -> NodeJsStatelessFuncResponse
        {
            throw AppserverError.NodeJsApp("not implemented")
        }
        func shutdown() async {
        }
        func shutdownProcess() {
        }
    }

    func testGeneral() async throws {
        let components = try await createTestComponents()

        let appFactory = NativeAppFactory(
            loggerFactory: components.loggerFactory,
            db: components.db,
            config: components.config,
            responseSender: components.responseSender,
            jsonEncoder: components.jsonEncoder,
            jsonDecoder: components.jsonDecoder,
            scheduler: components.scheduler,
            userSender: components.userSender,
        )

        let apps = await Apps(
            loggerFactory: components.loggerFactory,
            config: components.config,
            scheduler: components.scheduler,
            db: components.db,
            appFactory: AppFactory(
                db: components.db,
                nodeJsAppFactory: NodeJsAppFactory(
                    db: components.db,
                    config: components.config,
                    loggerFactory: components.loggerFactory,
                    globalAppLibComponents: GlobalAppLibComponents(
                        responseSender: components.responseSender,
                        userLogin: try UserLogin(
                            userSender: components.userSender,
                            scheduler: components.scheduler,
                        ),
                        userSender: components.userSender,
                        httpClient: HttpClientMock(),
                    ),
                    nodeProcess: NoopNodeJsAppApi(),
                    jsonEncoder: components.jsonEncoder,
                ),
            ),
            staticApps: [
                APP_ID: try appFactory.create(
                    appId: APP_ID,
                    statelessFuncs: statelessFuncs,
                    entityTypeFuncs: entityTypeFuncs,
                    typeRegistry: NativeTypeRegistry(map: [:]),
                )
            ],
        )

        try await generalTests(apps: apps, components: components)
    }
}
