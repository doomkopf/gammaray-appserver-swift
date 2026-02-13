final class NativeStatelessFunctions: StatelessFunctions {
    private let log: Logger
    private let libContainer: LibContainer
    private let responseSender: ResponseSender
    private let jsonDecoder: StringJSONDecoder
    private let funcs: [String: StatelessFunc]

    init(
        loggerFactory: LoggerFactory,
        libContainer: LibContainer,
        responseSender: ResponseSender,
        jsonDecoder: StringJSONDecoder,
        funcs: [String: StatelessFunc],
    ) {
        log = loggerFactory.createForClass(NativeStatelessFunctions.self)
        self.libContainer = libContainer
        self.responseSender = responseSender
        self.jsonDecoder = jsonDecoder
        self.funcs = funcs
    }

    func invoke(_ params: FunctionParams) async {
        guard let statelessFunc = funcs[params.theFunc] else {
            return
        }

        do {
            var decodedPayload: Decodable?
            if let payload = params.payload {
                decodedPayload = try jsonDecoder.decode(statelessFunc.payloadType, payload)
            }

            try statelessFunc.f(
                await libContainer.get(),
                decodedPayload,
                ApiRequestContextImpl(
                    requestId: params.ctx.requestId,
                    requestingUserId: params.ctx.requestingUserId,
                    clientRequestId: params.ctx.clientRequestId,
                    persistentSession: params.ctx.persistentSession,
                    responseSender: responseSender,
                ),
            )
        } catch {
            log.log(.ERROR, "Error in stateless function: \(params.theFunc)", error)
        }
    }
}
