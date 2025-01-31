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

struct NodeJsEntityFuncRequest: Encodable {
    let appId: String
    let requestId: String?
    let requestingUserId: String?
    let persistentLocalClientId: String?
    let id: String
    let type: String
    let efunc: String
    let entityJson: String?
    let paramsJson: String?
}

struct NodeJsFuncResponse: Decodable {
    let responseSender: NodeJsResponseSenderPayload?
    // TODO userSender payloads
    let entityFuncInvokes: [NodeJsEntityFuncInvokePayload]?
}

struct NodeJsEntityFuncResponse: Decodable {
    let general: NodeJsFuncResponse
    let action: NodeJsEntityAction
    let entityJson: String?
}

struct NodeJsStatelessFuncRequest: Encodable {
    let appId: String
    let requestId: String?
    let requestingUserId: String?
    let persistentLocalClientId: String?
    let sfunc: String
    let paramsJson: String?
}

struct NodeJsStatelessFuncResponse: Decodable {
    let general: NodeJsFuncResponse
}

struct NodeJsResponseSenderPayload: Decodable {
    let requestId: String
    let objJson: String
}

struct NodeJsEntityFuncInvokePayload: Decodable {
    let type: String
    let _func: String
    let entityId: String
    let paramsJson: String?
}
