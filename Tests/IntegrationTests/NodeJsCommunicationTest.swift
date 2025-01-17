import Foundation
import XCTest

@testable import Gammaray

final class NodeJsCommunicationTest: XCTestCase {
    func testCom() async throws {
        let reader = ResourceFileReaderImpl(module: Bundle.module)

        let config = try Config(reader: reader)

        let p = try NodeJsProcess(
            jsFile: "Resources/NodeJsCommunicationTest", module: Bundle.module,
            nodeJsBinaryPath: config.get(ConfigProperty.nodeJsBinaryPath))
        defer {
            p.shutdown()
        }
        await p.start()

        let scheduler = Scheduler()
        let idGen = RequestIdGenerator(localHost: "127.0.0.1", localPort: 123)
        let resultCallbacks = try ResultCallbacks(requestTimeoutMillis: 4000, scheduler: scheduler)
        let cmdProc = CommandProcessor(resultCallbacks: resultCallbacks)

        let remoteHost = try RemoteHost(
            requestIdGenerator: idGen,
            resultCallbacks: resultCallbacks,
            host: "127.0.0.1",
            port: 1234,
            sendTimeoutMillis: 3000,
            sendIntervalMillis: 2000,
            scheduler: scheduler,
            listener: cmdProc)

        var result = await remoteHost.request(cmd: 1, payload: "test1")
        XCTAssertEqual(result.data, "test1")

        result = await remoteHost.request(cmd: 1, payload: "test2")
        XCTAssertEqual(result.data, "test2")

        try await remoteHost.shutdown()
        await resultCallbacks.shutdown()
    }
}
