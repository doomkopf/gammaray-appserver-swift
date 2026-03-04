struct ApiRequestContextImpl: ApiRequestContext {
    let requestId: RequestId?
    let requestingUserId: EntityId?
    let clientRequestId: ClientRequestId?
    let persistentSession: GammarayPersistentSession?
    let responseSender: ResponseSender

    func sendResponse(objJson: Encodable & Sendable) {
        if let requestId {
            Task {
                await responseSender.send(requestId: requestId, payload: objJson)
            }
        }
    }
}
