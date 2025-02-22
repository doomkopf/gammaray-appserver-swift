protocol GammarayProtocolRequest: Sendable {
    func respond(payload: String) async
}
