@testable import Gammaray

let app = GammarayApp(
    sfunc: [
        try! FunctionName("echo"): echo,
        try! FunctionName("testUserLogin"): testUserLogin,
        try! FunctionName("loginFinished"): loginFinished,
    ],
    entity: [
        try! EntityTypeId("person"): EntityType(
            efunc: [
                try! FunctionName("createPerson"): createPerson,
                try! FunctionName("loadPerson"): loadPerson,
            ],
        )
    ],
)

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

struct PersonResponse: Encodable {
    let name: String
}

let loadPerson = EntityFunc(
    vis: .pub,
    payloadType: String.self,
    f: {
        @Sendable
        (
            entity: GammarayEntity?,
            id: EntityId,
            lib: Lib,
            payload: Decodable?,
            ctx: any ApiRequestContext,
        ) throws -> EntityFuncResult in
        let person = entity as! Person
        ctx.sendResponse(objJson: PersonResponse(name: person.getName()))
        return EntityFuncResult.none
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
            loginFinishedFunctionId: try FunctionName("loginFinished"),
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
