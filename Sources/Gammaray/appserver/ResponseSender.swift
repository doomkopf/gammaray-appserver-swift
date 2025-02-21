actor ResponseSender {
    private var idCounter = 0
    private var requests: [RequestId: WebserverRequest] = [:]

    func send(requestId: RequestId, objJson: String) async {
        guard let request = requests[requestId] else {
            return
        }

        await request.respond(body: objJson, status: .OK, headers: nil)
    }

    func addRequest(request: WebserverRequest) -> RequestId {
        let requestId = generateRequestId()
        requests[requestId] = request
        return requestId
    }

    private func generateRequestId() -> RequestId {
        idCounter += 1
        return RequestId(idCounter)
    }
}
