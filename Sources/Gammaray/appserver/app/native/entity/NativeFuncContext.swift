struct NativeFuncContext: FuncContext {
    let requestId: RequestId?
    let requestingUserId: EntityId?
    let responseSender: ResponseSender

    func sendResponse(objJson: String) {
        if let requestId {
            Task {
                await responseSender.send(requestId: requestId, objJson: objJson)
            }
        }
    }
}
