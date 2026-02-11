final class NativeStatelessFunctions: StatelessFunctions {
    private let log: Logger
    private let lib: Lib
    private let responseSender: ResponseSender
    private let jsonDecoder: StringJSONDecoder
    private let funcs: [String: StatelessFunc]

    init(
        loggerFactory: LoggerFactory,
        lib: Lib,
        responseSender: ResponseSender,
        jsonDecoder: StringJSONDecoder,
        funcs: [String: StatelessFunc],
    ) {
        log = loggerFactory.createForClass(NativeStatelessFunctions.self)
        self.lib = lib
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
                lib,
                decodedPayload,
                ApiRequestContextImpl(
                    requestId: params.ctx.requestId,
                    requestingUserId: params.ctx.requestingUserId,
                    clientRequestId: params.ctx.clientRequestId,
                    responseSender: responseSender,
                ),
            )
        } catch {
            log.log(.ERROR, "Error in stateless function: \(params.theFunc)", error)
        }
    }
}
