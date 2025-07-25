struct RequestContext {
    let requestId: RequestId?
    let requestingUserId: EntityId?
    let clientRequestId: String?
}

struct EntityParams {
    let type: String
    let id: EntityId
}

struct FunctionParams {
    let theFunc: String
    let ctx: RequestContext
    let payload: String?
}

let EMPTY_REQUEST_CONTEXT = RequestContext(
    requestId: nil, requestingUserId: nil, clientRequestId: nil
)
