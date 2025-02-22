struct RequestContext {
    let requestId: RequestId?
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
    requestId: nil, requestingUserId: nil
)
