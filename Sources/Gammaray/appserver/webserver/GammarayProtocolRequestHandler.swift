private struct Message: Decodable {
    let appId: String
    let theFunc: String
    let entityMsg: EntityMessage?
    let payload: String?
}

private struct EntityMessage: Decodable {
    let entityType: String
    let entityId: String
}

final class GammarayProtocolRequestHandler: Sendable {
    private let log: Logger
    private let jsonDecoder: StringJSONDecoder
    private let responseSender: ResponseSender
    private let apps: Apps

    init(
        loggerFactory: LoggerFactory,
        jsonDecoder: StringJSONDecoder,
        responseSender: ResponseSender,
        apps: Apps
    ) {
        log = loggerFactory.createForClass(GammarayProtocolRequestHandler.self)
        self.jsonDecoder = jsonDecoder
        self.responseSender = responseSender
        self.apps = apps
    }

    func handle(request: GammarayProtocolRequest, payload: String) async {
        let msg: Message
        do {
            msg = try jsonDecoder.decode(Message.self, payload)
        } catch {
            log.log(.ERROR, "Error deserializing payload", error)
            return
        }

        let requestId = await responseSender.addRequest(request: request)
        var entityParams: EntityParams?
        if let entityMsg = msg.entityMsg {
            entityParams = EntityParams(type: entityMsg.entityType, id: entityMsg.entityId)
        }

        await apps.handleFunc(
            appId: msg.appId,
            params: FunctionParams(
                theFunc: msg.theFunc,
                ctx: RequestContext(
                    requestId: requestId,
                    requestingUserId: nil
                ),
                payload: msg.payload
            ),
            entityParams: entityParams
        )
    }
}
