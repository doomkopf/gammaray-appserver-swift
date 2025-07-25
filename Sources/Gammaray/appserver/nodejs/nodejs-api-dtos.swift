struct NodeJsSetAppRequest: Encodable {
    let id: String
    let code: String
}

struct NodeJsSetAppResponse: Decodable {
    let error: NodeJsSetAppErrorResponse?
}

struct NodeJsSetAppErrorResponse: Decodable {
    let type: NodeJsSetAppErrorResponseType
    let message: String
}

enum NodeJsSetAppErrorResponseType: Int, Decodable {
    case SCRIPT_EVALUATION = 0
}

struct NodeJsGetAppDefinitionRequest: Encodable {
    let appId: String
}

struct NodeJsGammarayApp: Decodable {
    let sfunc: [String: NodeJsStatelessFunc]
    let entity: [String: NodeJsEntityType]
}

struct NodeJsStatelessFunc: Decodable {
    let vis: NodeJsFuncVisibility
}

struct NodeJsEntityType: Decodable {
    let efunc: [String: NodeJsEntityFunc]
}

struct NodeJsEntityFunc: Decodable {
    let vis: NodeJsFuncVisibility
}

enum NodeJsFuncVisibility: Int, Decodable {
    case PRI = 1
    case PUB = 2

    func toCore() -> FuncVisibility {
        switch self {
        case .PRI:
            return FuncVisibility.pri
        case .PUB:
            return FuncVisibility.pub
        }
    }
}

enum NodeJsCommands: Int {
    case ENTITY_FUNC = 1
    case STATELESS_FUNC = 2
    case APP_DEFINITION = 3
    case SET_APP = 4
}

enum NodeJsEntityAction: Int, Decodable {
    case NONE = 0
    case SET_ENTITY = 1
    case DELETE_ENTITY = 2

    func toCore() -> EntityAction {
        switch self {
        case .NONE:
            return EntityAction.none
        case .SET_ENTITY:
            return EntityAction.setEntity
        case .DELETE_ENTITY:
            return EntityAction.deleteEntity
        }
    }
}

struct NodeJsFuncRequest: Encodable {
    let appId: String
    let requestId: String?
    let requestingUserId: String?
    let clientRequestId: String?
    let fun: String
    let paramsJson: String?
}

struct NodeJsEntityFuncRequest: Encodable {
    let funcRequest: NodeJsFuncRequest
    let id: String
    let type: String
    let entityJson: String?
}

struct NodeJsFuncResponse: Decodable {
    let responseSenderSend: NodeJsResponseSenderSend?
    let userFunctionsLogin: [NodeJsUserFunctionsLogin]?
    let userFunctionsLogout: [String]?
    let userFunctionsSend: [NodeJsUserFunctionsSend]?
    let entityFunctionsInvoke: [NodeJsEntityFunctionsInvoke]?
    let httpClientRequest: [NodeJsHttpClientRequest]?
    let loggerLog: [NodeJsLoggerLog]?
}

struct NodeJsEntityFuncResponse: Decodable {
    let general: NodeJsFuncResponse
    let action: NodeJsEntityAction
    let entityJson: String?
}

struct NodeJsStatelessFuncResponse: Decodable {
    let general: NodeJsFuncResponse
}

struct NodeJsResponseSenderSend: Decodable {
    let requestId: String
    let objJson: String
}

struct NodeJsUserFunctionsLogin: Decodable {
    let userId: String
    let funcId: String
    let customCtxJson: String?
}

struct NodeJsUserFunctionsSend: Decodable {
    let userId: String
    let objJson: String
}

struct NodeJsEntityFunctionsInvoke: Decodable {
    let type: String
    let _func: String
    let entityId: String
    let paramsJson: String?
}

struct NodeJsHttpClientRequest: Decodable {
    let url: String
    let method: NodeJsHttpMethod
    let body: String?
    let headers: [NodeJsHttpHeader]
    let resultFunc: String
    let requestCtxJson: String?
}

enum NodeJsHttpMethod: String, Decodable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

struct NodeJsHttpHeader: Decodable {
    let key: String
    let value: String
}

struct NodeJsLoggerLog: Decodable {
    let logLevel: NodeJsLogLevel
    let message: String
}

enum NodeJsLogLevel: String, Decodable {
    case ERROR = "ERROR"
    case WARN = "WARN"
    case INFO = "INFO"
    case DEBUG = "DEBUG"
}
