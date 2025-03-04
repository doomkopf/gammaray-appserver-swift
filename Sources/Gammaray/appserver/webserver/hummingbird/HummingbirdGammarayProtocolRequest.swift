actor HummingbirdGammarayProtocolRequest: GammarayProtocolRequest {
    private let wait = WaitContext()
    private var payload: String?

    func respond(payload: String) {
        self.payload = payload
        wait.signal()
    }

    func cancel() {
        wait.signal()
    }

    func awaitResponse() async -> String? {
        await wait.waitForSignal()
        return payload
    }
}
