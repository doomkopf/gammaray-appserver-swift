struct RequestContext {
    let requestId: String?
    let persistentLocalClientId: String?
    let requestingUserId: EntityId?
}

struct EntityParams {
    let type: String
    let id: EntityId
}

struct FunctionParams {
    let theFunc: String
    let ctx: RequestContext
    let paramsJson: String?
}

let EMPTY_REQUEST_CONTEXT = RequestContext(
    requestId: nil, persistentLocalClientId: nil, requestingUserId: nil
)
