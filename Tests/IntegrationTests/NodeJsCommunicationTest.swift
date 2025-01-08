import XCTest

@testable import Gammaray

final class NodeJsCommunicationTest: XCTestCase {
    func testCom() async throws {
        let p = try NodeJsProcess(
            jsFile: "Resources/NodeJsCommunicationTest", module: Bundle.module)
        defer {
            p.shutdown()
        }
        await p.start()

        let scheduler = Scheduler()
        let idGen = RequestIdGenerator(localHost: "127.0.0.1", localPort: 123)
        let resultCallbacks = try ResultCallbacks(
            requestTimeoutMillis: 4000)
        await resultCallbacks.start(scheduler: scheduler)
        let cmdProc = CommandProcessor(resultCallbacks: resultCallbacks)

        let remoteHost = try RemoteHost(
            requestIdGenerator: idGen,
            resultCallbacks: resultCallbacks,
            host: "127.0.0.1",
            port: 1234,
            sendTimeoutMillis: 3000,
            sendIntervalMillis: 2000,
            listener: cmdProc)
        await remoteHost.start(scheduler: scheduler)

        var result = await remoteHost.request(cmd: 1, payload: "test1")
        XCTAssertEqual(result.data, "test1")

        result = await remoteHost.request(cmd: 1, payload: "test2")
        XCTAssertEqual(result.data, "test2")

        try await remoteHost.shutdown()
        await resultCallbacks.shutdown()
    }
}
