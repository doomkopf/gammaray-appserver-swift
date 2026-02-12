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

    let echo = StatelessFunc(
        vis: .pub,
        payloadType: String.self,
        f: {
            @Sendable
            (lib: Lib, payload: Decodable?, ctx: ApiRequestContext) throws -> Void in
            ctx.sendResponse(objJson: payload as! String)
        },
    )

    struct CreatePersonRequest: Decodable {
        let entityName: String
    }

    class Person: Codable {
        private var name: String

        init(name: String) {
            self.name = name
        }

        func getName() -> String {
            name
        }
    }

    let createPerson = EntityFunc(
        vis: .pub,
        payloadType: CreatePersonRequest.self,
        f: {
            @Sendable
            (
                entity: GammarayEntity?,
                id: EntityId,
                lib: Lib,
                payload: Decodable?,
                ctx: any ApiRequestContext,
            ) throws -> EntityFuncResult in
            let request = payload as! CreatePersonRequest
            let person = Person(name: request.entityName)
            return EntityFuncResult.setEntity(person)
        }
    )

    struct CustomCtx: Encodable {
        let myCustomContext: String
    }

    let testUserLogin = StatelessFunc(
        vis: .pub,
        payloadType: String.self,
        f: {
            @Sendable
            (lib: Lib, payload: Decodable?, ctx: ApiRequestContext) throws -> Void in
            lib.user.login(
                userId: try EntityId("myUserId"),
                loginFinishedFunctionId: "loginFinished",
                ctxPayload: CustomCtx(myCustomContext: "test"),
                ctx: ctx,
            )
        },
    )

    struct PushMessage: Encodable {
        let msg: String
    }

    let loginFinished = StatelessFunc(
        vis: .pub,
        payloadType: LoginResult.self,
        f: {
            @Sendable
            (lib: Lib, payload: Decodable?, ctx: ApiRequestContext) throws -> Void in
            let loginResult = payload as! LoginResult
            ctx.sendResponse(objJson: loginResult)
            lib.user.send(userId: try EntityId("myUserId"), obj: PushMessage(msg: "pushed message"))
        },
    )

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
                    statelessFuncs: [
                        "echo": echo,
                        "testUserLogin": testUserLogin,
                        "loginFinished": loginFinished,
                    ],
                    entityTypeFuncs: [
                        "person": [
                            "createPerson": createPerson
                        ]
                    ],
                    typeRegistry: NativeTypeRegistry(map: [:]),
                )
            ],
        )

        try await generalTests(apps: apps, components: components)
    }
}
