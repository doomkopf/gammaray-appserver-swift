import Foundation

@available(macOS 10.15, *)
final class NodeJsProcess: Sendable {
    private let proc: Process

    init(jsFile: String, module: Bundle) throws {
        guard
            let resourceUrl = module.url(
                forResource: jsFile,
                withExtension: "js")
        else {
            throw AppserverError.NodeJsApp("Failed to locate js file: \(jsFile)")
        }

        proc = Process()
        proc.launchPath = "todo-path-to-node-binary"
        proc.arguments = [resourceUrl.path]
        try proc.run()
    }

    func start() async {
        await gammaraySleep(250)
    }

    func shutdown() {
        proc.terminate()
        proc.waitUntilExit()
    }
}
