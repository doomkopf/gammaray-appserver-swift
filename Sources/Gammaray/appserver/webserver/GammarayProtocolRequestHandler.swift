private struct Message: Decodable {
    let app: AppMessage?
    let admin: AdminMessage?
}

private struct AppMessage: Codable {
    let appId: String
    let theFunc: String
    let entityMsg: EntityMessage?
    let payload: String?
    let sid: String?
    let rid: String?
}

private struct EntityMessage: Codable {
    let entityType: String
    let entityId: String
}

private struct AdminMessage: Decodable {
    let type: AdminCommandType
    let payload: String
}

final class GammarayProtocolRequestHandler: Sendable {
    private let log: Logger
    private let jsonEncoder: StringJSONEncoder
    private let jsonDecoder: StringJSONDecoder
    private let responseSender: ResponseSender
    private let apps: Apps
    private let adminCommandProcessor: AdminCommandProcessor
    private let userLogin: UserLogin

    init(
        loggerFactory: LoggerFactory,
        jsonEncoder: StringJSONEncoder,
        jsonDecoder: StringJSONDecoder,
        responseSender: ResponseSender,
        apps: Apps,
        adminCommandProcessor: AdminCommandProcessor,
        userLogin: UserLogin,
    ) {
        log = loggerFactory.createForClass(GammarayProtocolRequestHandler.self)
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        self.responseSender = responseSender
        self.apps = apps
        self.adminCommandProcessor = adminCommandProcessor
        self.userLogin = userLogin
    }

    func handle(
        request: GammarayProtocolRequest,
        persistentSession: GammarayPersistentSession?,
        payload: String,
    ) async {
        let msg: Message
        do {
            msg = try jsonDecoder.decode(Message.self, payload)
        } catch {
            log.log(.ERROR, "Error deserializing payload", error)
            return
        }

        if let appMsg = msg.app {
            await handleAppMessage(
                request: request,
                persistentSession: persistentSession,
                appMsg: appMsg,
            )
        } else if let adminMsg = msg.admin {
            await handleAdminMessage(request: request, adminMsg: adminMsg)
        }
    }

    private func handleAppMessage(
        request: GammarayProtocolRequest,
        persistentSession: GammarayPersistentSession?,
        appMsg: AppMessage,
    ) async {
        if log.isLevel(.DEBUG) {
            log.log(.DEBUG, "RECV - \(jsonEncoder.encode(appMsg))", nil)
        }

        var entityParams: EntityParams?
        if let entityMsg = appMsg.entityMsg {
            let entityId: EntityId
            do {
                entityId = try EntityId(entityMsg.entityId)
            } catch {
                log.log(.ERROR, "Error creating entityId", error)
                return
            }

            let entityTypeId: EntityTypeId
            do {
                entityTypeId = try EntityTypeId(entityMsg.entityType)
            } catch {
                log.log(.ERROR, "Error creating entityTypeId", error)
                return
            }

            entityParams = EntityParams(
                typeId: entityTypeId,
                id: entityId
            )
        }

        let requestId = await responseSender.addRequest(request: request)

        var userId: EntityId? = nil
        if let sessionId = appMsg.sid {
            userId = await userLogin.getUserId(sessionId: sessionId)
        } else if let userIdFromSession = await persistentSession?.getUserId() {
            userId = userIdFromSession
        }

        let theFunc: FunctionName
        do {
            theFunc = try FunctionName(appMsg.theFunc)
        } catch {
            log.log(.ERROR, "Error creating functionName", error)
            return
        }

        let appId: AppId
        do {
            appId = try AppId(appMsg.appId)
        } catch {
            log.log(.ERROR, "Error creating appId", error)
            return
        }

        var clientRequestId: ClientRequestId?
        if let rid = appMsg.rid {
            do {
                clientRequestId = try ClientRequestId(rid)
            } catch {
                log.log(.ERROR, "Error creating clientRequestId", error)
                return
            }
        }

        await apps.handleFunc(
            appId: appId,
            params: FunctionParams(
                theFunc: theFunc,
                ctx: RequestContext(
                    requestId: requestId,
                    requestingUserId: userId,
                    clientRequestId: clientRequestId,
                    persistentSession: persistentSession,
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
