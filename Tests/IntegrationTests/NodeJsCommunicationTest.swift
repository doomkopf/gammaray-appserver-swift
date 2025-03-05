import Foundation
import XCTest

@testable import Gammaray

final class NodeJsCommunicationTest: XCTestCase {
    func testCom() async throws {
        let reader = ResourceFileReaderImpl(module: Bundle.module)

        let config = try Config(reader: reader)

        let p = try NodeJsProcess(
            jsFile: "Resources/NodeJsCommunicationTest", module: Bundle.module,
            nodeJsBinaryPath: config.getString(ConfigProperty.nodeJsBinaryPath))
        defer {
            p.shutdown()
        }
        await p.start()

        let scheduler = SchedulerImpl()
        let idGen = RequestIdGenerator(localHost: LOCAL_HOST, localPort: NODE_JS_PROCESS_LOCAL_PORT)
        let resultCallbacks = try ResultCallbacks(requestTimeoutMillis: 4000, scheduler: scheduler)
        let cmdProc = CommandProcessor(
            loggerFactory: LoggerFactory(),
            resultCallbacks: resultCallbacks
        )

        let remoteHost = try RemoteHost(
            requestIdGenerator: idGen,
            resultCallbacks: resultCallbacks,
            host: LOCAL_HOST,
            port: NODE_JS_PROCESS_PORT,
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
