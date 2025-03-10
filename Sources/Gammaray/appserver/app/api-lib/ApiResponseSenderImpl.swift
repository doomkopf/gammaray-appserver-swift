struct ApiResponseSenderImpl: ApiResponseSender {
    let responseSender: ResponseSender

    func send(requestId: RequestId, obj: String) {
        Task {
            await responseSender.send(requestId: requestId, objJson: obj)
        }
    }
}
