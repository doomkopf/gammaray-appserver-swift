import XCTest

@testable import Gammaray

final class ResponseSenderTest: XCTestCase {
    func testSend() async {
        actor GammarayProtocolRequestMock: GammarayProtocolRequest {
            var respondPayload: String?

            func respond(payload: String) {
                respondPayload = payload
            }

            func cancel() {
            }
        }

        struct CacheMock: Cache {
            typealias V = GammarayProtocolRequest

            let request = GammarayProtocolRequestMock()

            func setListener(_ listener: any CacheListener<V>) {
            }

            func put(key: String, value: V) {
            }

            func get(key: String) -> V? {
                nil
            }

            func remove(_ key: String) -> V? {
                request
            }

            func removeAnyEntry() -> CacheEntry<V>? {
                nil
            }

            func forEachEntry(fun: (String, V) -> Void) {
            }

            var size: Int {
                0
            }

            func cleanup() {
            }

            func clear() {
            }
        }

        let cache = CacheMock()

        let subject = ResponseSender(
            scheduler: NoopScheduler(),
            requestsCache: cache
        )

        await subject.send(requestId: "id", objJson: "thePayload")

        let respondPayload = await cache.request.respondPayload

        XCTAssertEqual("thePayload", respondPayload)
    }
}
