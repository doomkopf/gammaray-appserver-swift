import Hummingbird
import HummingbirdWebSocket

func runWebserver(components: AppserverComponents) async throws {
    let hummingbird = Application(
        responder: CallbackResponder<BasicRequestContext> {
            request, _ -> Response in

            if request.uri.string == "/gamapi" {
                var buf = try await request.body.collect(upTo: 65536)
                guard let requestBody = buf.readString(length: buf.readableBytes) else {
                    return Response(status: HTTPResponse.Status.badRequest)
                }

                let gmrRequest = HummingbirdGammarayProtocolRequest()

                await components.protocolRequestHandler.handle(
                    request: gmrRequest,
                    persistentSession: nil,
                    payload: requestBody,
                )

                guard let responseBody = await gmrRequest.awaitResponse() else {
                    return Response(status: HTTPResponse.Status.internalServerError)
                }

                return Response(
                    status: HTTPResponse.Status.ok,
                    body: ResponseBody(byteBuffer: ByteBuffer(string: responseBody))
                )
            }

            return Response(status: HTTPResponse.Status.badRequest)
        },
        server: .http1WebSocketUpgrade { request, channel, logger in
            guard request.path == "/gamwsapi" else {
                return .dontUpgrade
            }
            return .upgrade([:]) { inbound, outbound, context in
                // channel connected
                let session = HummingbirdGammarayPersistentSession(outbound: outbound)
                do {
                    for try await frame in inbound {
                        var buf = frame.data
                        if let frameStr = buf.readString(length: buf.readableBytes) {
                            await components.protocolRequestHandler.handle(
                                request: session,
                                persistentSession: session,
                                payload: frameStr,
                            )
                        }
                    }
                } catch {
                    // channel disconnected
                }
                // channel closed (gracefully?)
            }
        },
        configuration: .init(
            address: .hostname("127.0.0.1", port: components.config.getInt(.webserverPort)))
    )

    try await hummingbird.runService()
}
