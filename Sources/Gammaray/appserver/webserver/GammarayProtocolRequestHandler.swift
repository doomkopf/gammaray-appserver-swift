private struct Message: Decodable {
    let app: AppMessage?
    let admin: AdminMessage?
}

private struct AppMessage: Decodable {
    let appId: String
    let theFunc: String
    let entityMsg: EntityMessage?
    let payload: String?
    let sid: String?
    let rid: String?
}

private struct EntityMessage: Decodable {
    let entityType: String
    let entityId: String
}

private struct AdminMessage: Decodable {
    let type: AdminCommandType
    let payload: String
}

final class GammarayProtocolRequestHandler: Sendable {
    private let log: Logger
    private let jsonDecoder: StringJSONDecoder
    private let responseSender: ResponseSender
    private let apps: Apps
    private let adminCommandProcessor: AdminCommandProcessor
    private let userLogin: UserLogin

    init(
        loggerFactory: LoggerFactory,
        jsonDecoder: StringJSONDecoder,
        responseSender: ResponseSender,
        apps: Apps,
        adminCommandProcessor: AdminCommandProcessor,
        userLogin: UserLogin,
    ) {
        log = loggerFactory.createForClass(GammarayProtocolRequestHandler.self)
        self.jsonDecoder = jsonDecoder
        self.responseSender = responseSender
        self.apps = apps
        self.adminCommandProcessor = adminCommandProcessor
        self.userLogin = userLogin
    }

    func handle(request: GammarayProtocolRequest, payload: String) async {
        let msg: Message
        do {
            msg = try jsonDecoder.decode(Message.self, payload)
        } catch {
            log.log(.ERROR, "Error deserializing payload", error)
            return
        }

        if let appMsg = msg.app {
            await handleAppMessage(request: request, appMsg: appMsg)
        } else if let adminMsg = msg.admin {
            await handleAdminMessage(request: request, adminMsg: adminMsg)
        }
    }

    private func handleAppMessage(request: GammarayProtocolRequest, appMsg: AppMessage) async {
        var entityParams: EntityParams?
        if let entityMsg = appMsg.entityMsg {
            let entityId: EntityId
            do {
                entityId = try EntityIdImpl(entityMsg.entityId)
            } catch {
                log.log(.ERROR, "Error creating entityId", error)
                return
            }
            entityParams = EntityParams(
                type: entityMsg.entityType,
                id: entityId
            )
        }

        let requestId = await responseSender.addRequest(request: request)
        var userId: EntityId? = nil
        if let sessionId = appMsg.sid {
            userId = await userLogin.getUserId(sessionId: sessionId)
        }

        await apps.handleFunc(
            appId: appMsg.appId,
            params: FunctionParams(
                theFunc: appMsg.theFunc,
                ctx: RequestContext(
                    requestId: requestId,
                    requestingUserId: userId,
                    clientRequestId: appMsg.rid,
                ),
                payload: appMsg.payload
            ),
            entityParams: entityParams
        )
    }

    private func handleAdminMessage(request: GammarayProtocolRequest, adminMsg: AdminMessage) async
    {
        await adminCommandProcessor.process(
            request: request, type: adminMsg.type, payload: adminMsg.payload)
    }
}
