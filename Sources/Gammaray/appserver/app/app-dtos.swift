struct RequestContext {
    let requestId: RequestId?
    let requestingUserId: EntityId?
    let clientRequestId: String?
    let persistentSession: GammarayPersistentSession?
}

struct EntityParams {
    let typeId: EntityTypeId
    let id: EntityId
}

struct FunctionParams {
    let theFunc: String
    let ctx: RequestContext
    let payload: String?
}

let EMPTY_REQUEST_CONTEXT = RequestContext(
    requestId: nil, requestingUserId: nil, clientRequestId: nil, persistentSession: nil
)
