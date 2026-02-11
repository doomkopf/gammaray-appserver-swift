import XCTest

@testable import Gammaray

final class NodeJsGeneralTest: XCTestCase {
    func testGeneral() async throws {
        let components = try await createTestComponents()

        let nodeApi = try NodeJsAppApiImpl(
            loggerFactory: components.loggerFactory,
            config: components.config,
            scheduler: components.scheduler,
        )
        defer {
            nodeApi.shutdownProcess()
        }
        await nodeApi.start()

        let apps = Apps(
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
                    nodeProcess: nodeApi,
                    jsonEncoder: components.jsonEncoder,
                ),
            ),
            staticApps: [:],
        )

        let admin = AdminCommandProcessor(
            loggerFactory: components.loggerFactory,
            jsonDecoder: components.jsonDecoder,
            jsonEncoder: components.jsonEncoder,
            deployAppCommandProcessor: DeployAppCommandProcessor(
                loggerFactory: components.loggerFactory,
                jsonEncoder: components.jsonEncoder,
                apps: apps,
                config: components.config,
            ),
        )

        let code = try components.reader.readStringFile(name: "GeneralTest", ext: "js")
        await admin.process(
            request: NoopGammarayProtocolRequest(),
            type: .DEPLOY_NODEJS_APP,
            payload: components.jsonEncoder.encode(
                DeployNodeJsAppCommandRequest(
                    appId: APP_ID, pw: "thisdefaultpasswordshouldnotbeused", script: code
                ),
            ),
        )

        try await generalTests(apps: apps, components: components)
    }
}
