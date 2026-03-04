struct RequestContext {
    let requestId: RequestId?
    let requestingUserId: EntityId?
    let clientRequestId: ClientRequestId?
    let persistentSession: GammarayPersistentSession?
}

struct EntityParams {
    let typeId: EntityTypeId
    let id: EntityId
}

struct FunctionParams {
    let theFunc: FunctionName
    let ctx: RequestContext
    let payload: String?
}

let EMPTY_REQUEST_CONTEXT = RequestContext(
    requestId: nil, requestingUserId: nil, clientRequestId: nil, persistentSession: nil
)
