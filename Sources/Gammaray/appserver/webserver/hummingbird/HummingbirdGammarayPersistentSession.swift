import HummingbirdWebSocket

actor HummingbirdGammarayPersistentSession: GammarayPersistentSession, GammarayProtocolRequest {
    private let outbound: WebSocketOutboundWriter
    private var userId: EntityId?

    init(
        outbound: WebSocketOutboundWriter,
    ) {
        self.outbound = outbound
    }

    func respond(payload: String) async {
        await send(payload: payload)
    }

    func cancel() async {
        // only necessary for non-persistent client requests
    }

    func send(payload: String) async {
        do {
            try await outbound.write(.text(payload))
        } catch {
            // TODO log
        }
    }

    func assignUserId(userId: EntityId) {
        self.userId = userId
    }

    func getUserId() -> EntityId? {
        userId
    }
}
