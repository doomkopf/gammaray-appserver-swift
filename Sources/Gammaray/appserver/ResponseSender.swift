protocol ResponseSender: Sendable {
    func send(requestId: String, objJson: String) async
}
