import Foundation

protocol NodeJsAppProcess: Sendable {
    func setApp(_ request: NodeJsSetAppRequest) async throws -> NodeJsSetAppResponse
    func getAppDefinition(_ request: NodeJsGetAppDefinitionRequest) async throws
        -> NodeJsGammarayApp
    func entityFunc(_ request: NodeJsEntityFuncRequest) async throws -> NodeJsEntityFuncResponse
    func statelessFunc(_ request: NodeJsStatelessFuncRequest) async throws
        -> NodeJsStatelessFuncResponse
}

@available(macOS 10.15, *)
final class NodeJsAppProcessImpl: NodeJsAppProcess {
    private let jsonEncoder = StringJSONEncoder()
    private let jsonDecoder = StringJSONDecoder()
    private let resultCallbacks: ResultCallbacks
    private let remoteProcess: RemoteHost
    private let process: NodeJsProcess

    init(
        config: Config,
        // TODO move all those values to Config
        localHost: String,
        localPort: Int,
        requestTimeoutMillis: Int64,
        sendTimeoutMillis: Int64,
        sendIntervalMillis: Int64,
        nodeJsProcessPort: Int
    ) throws {
        let idGen = RequestIdGenerator(localHost: localHost, localPort: localPort)
        resultCallbacks = try ResultCallbacks(requestTimeoutMillis: requestTimeoutMillis)
        let cmdProc = CommandProcessor(resultCallbacks: resultCallbacks)

        remoteProcess = try RemoteHost(
            requestIdGenerator: idGen,
            resultCallbacks: resultCallbacks,
            host: localHost,
            port: nodeJsProcessPort,
            sendTimeoutMillis: sendTimeoutMillis,
            sendIntervalMillis: sendIntervalMillis,
            listener: cmdProc)

        process = try NodeJsProcess(
            jsFile: "Resources/NodeJsAppProcess", module: Bundle.module,
            nodeJsBinaryPath: config.get(ConfigProperty.nodeJsBinaryPath))
    }

    func start(scheduler: Scheduler) async {
        await process.start()
        await resultCallbacks.start(scheduler: scheduler)
        await remoteProcess.start(scheduler: scheduler)
    }

    func setApp(_ request: NodeJsSetAppRequest) async throws -> NodeJsSetAppResponse {
        let result = await remoteProcess.request(
            cmd: NodeJsCommands.SET_APP.rawValue, payload: jsonEncoder.encode(request))

        if let resultData = result.data {
            return try jsonDecoder.decode(NodeJsSetAppResponse.self, resultData)
        }

        if let resultError = result.error {
            throw AppserverError.NodeJsApp(
                "setApp failed with error type=\(resultError)")
        }

        throw AppserverError.NodeJsApp("setApp failed in an unexpected case")
    }

    func getAppDefinition(_ request: NodeJsGetAppDefinitionRequest) async throws
        -> NodeJsGammarayApp
    {
        let result = await remoteProcess.request(
            cmd: NodeJsCommands.APP_DEFINITION.rawValue, payload: jsonEncoder.encode(request))

        if let resultData = result.data {
            return try jsonDecoder.decode(NodeJsGammarayApp.self, resultData)
        }

        if let resultError = result.error {
            throw AppserverError.NodeJsApp(
                "getAppDefinition failed with error type=\(resultError)")
        }

        throw AppserverError.NodeJsApp("getAppDefinition failed in an unexpected case")
    }

    func entityFunc(_ request: NodeJsEntityFuncRequest) async throws -> NodeJsEntityFuncResponse {
        let result = await remoteProcess.request(
            cmd: NodeJsCommands.ENTITY_FUNC.rawValue, payload: jsonEncoder.encode(request))

        if let resultData = result.data {
            return try jsonDecoder.decode(NodeJsEntityFuncResponse.self, resultData)
        }

        if let resultError = result.error {
            throw AppserverError.NodeJsApp("entityFunc failed with error type=\(resultError)")
        }

        throw AppserverError.NodeJsApp("entityFunc failed in an unexpected case")
    }

    func statelessFunc(_ request: NodeJsStatelessFuncRequest) async throws
        -> NodeJsStatelessFuncResponse
    {
        let result = await remoteProcess.request(
            cmd: NodeJsCommands.STATELESS_FUNC.rawValue, payload: jsonEncoder.encode(request))

        if let resultData = result.data {
            return try jsonDecoder.decode(NodeJsStatelessFuncResponse.self, resultData)
        }

        if let resultError = result.error {
            throw AppserverError.NodeJsApp(
                "statelessFunc failed with error type=\(resultError)")
        }

        throw AppserverError.NodeJsApp("statelessFunc failed in an unexpected case")
    }

    func shutdown() async throws {
        await resultCallbacks.shutdown()
        try await remoteProcess.shutdown()
        shutdownProcess()
    }

    func shutdownProcess() {
        process.shutdown()
    }
}
