actor ResponseSender {
    private var idCounter = 0
    private var requests: [RequestId: GammarayProtocolRequest] = [:]

    func send(requestId: RequestId, objJson: String) async {
        guard let request = requests[requestId] else {
            return
        }

        requests.removeValue(forKey: requestId)

        await request.respond(payload: objJson)
    }

    func addRequest(request: GammarayProtocolRequest) -> RequestId {
        let requestId = generateRequestId()
        requests[requestId] = request
        return requestId
    }

    private func generateRequestId() -> RequestId {
        idCounter += 1
        return RequestId(idCounter)
    }
}
