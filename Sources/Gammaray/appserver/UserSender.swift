protocol UserSender: Sendable {
    func send(userId: EntityId, payload: Encodable & Sendable) async
    func putUserSession(session: GammarayPersistentSession, userId: EntityId) async
    func removeUserSession(userId: EntityId) async
}

actor UserSenderImpl: UserSender {
    private let log: Logger
    private let jsonEncoder: StringJSONEncoder

    private var userId2Session: [String: GammarayPersistentSession] = [:]

    init(
        loggerFactory: LoggerFactory,
        jsonEncoder: StringJSONEncoder,
    ) {
        log = loggerFactory.createForClass(UserSenderImpl.self)
        self.jsonEncoder = jsonEncoder
    }

    func send(userId: EntityId, payload: Encodable & Sendable) async {
        guard let session = userId2Session[userId.value] else {
            return
        }

        await session.send(payload: jsonEncoder.encode(payload))
        if log.isLevel(.DEBUG) {
            log.log(.DEBUG, "SEND - userId=\(userId.value) payload=\(payload)", nil)
        }
    }

    func putUserSession(session: GammarayPersistentSession, userId: EntityId) async {
        userId2Session[userId.value] = session
        await session.assignUserId(userId: userId)
    }

    func removeUserSession(userId: EntityId) {
        userId2Session.removeValue(forKey: userId.value)
    }
}
