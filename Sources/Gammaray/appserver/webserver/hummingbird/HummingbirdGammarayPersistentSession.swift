import HummingbirdWebSocket

actor HummingbirdGammarayPersistentSession: GammarayPersistentSession, GammarayProtocolRequest {
    private let log: Logger
    private let outbound: WebSocketOutboundWriter
    private var userId: EntityId?

    init(
        loggerFactory: LoggerFactory,
        outbound: WebSocketOutboundWriter,
    ) {
        log = loggerFactory.createForClass(HummingbirdGammarayPersistentSession.self)
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
            log.log(.ERROR, "Error writing to websocket", error)
        }
    }

    func assignUserId(userId: EntityId) {
        self.userId = userId
    }

    func getUserId() -> EntityId? {
        userId
    }
}
