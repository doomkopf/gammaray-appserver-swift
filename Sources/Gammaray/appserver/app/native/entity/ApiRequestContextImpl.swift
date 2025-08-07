struct ApiRequestContextImpl: ApiRequestContext {
    let requestId: RequestId?
    let requestingUserId: EntityId?
    let clientRequestId: String?
    let responseSender: ResponseSender

    func sendResponse(objJson: String) {
        if let requestId {
            Task {
                await responseSender.send(requestId: requestId, payload: objJson)
            }
        }
    }
}
