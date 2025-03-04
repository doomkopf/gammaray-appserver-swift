protocol GammarayProtocolRequest: Sendable {
    func respond(payload: String) async
    func cancel() async
}
