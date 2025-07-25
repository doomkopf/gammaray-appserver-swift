import Foundation

protocol NodeJsAppApi: Sendable {
    func setApp(_ request: NodeJsSetAppRequest) async throws -> NodeJsSetAppResponse
    func getAppDefinition(_ request: NodeJsGetAppDefinitionRequest) async throws
        -> NodeJsGammarayApp
    func entityFunc(_ request: NodeJsEntityFuncRequest) async throws -> NodeJsEntityFuncResponse
    func statelessFunc(_ request: NodeJsFuncRequest) async throws
        -> NodeJsStatelessFuncResponse
    func shutdown() async
    func shutdownProcess()
}

final class NodeJsAppApiImpl: NodeJsAppApi {
    private let log: Logger
    private let jsonEncoder = StringJSONEncoder()
    private let jsonDecoder = StringJSONDecoder()
    private let resultCallbacks: ResultCallbacks
    private let remoteProcessConnection: RemoteHost
    private let process: NodeJsProcess

    init(
        loggerFactory: LoggerFactory,
        config: Config,
        scheduler: Scheduler
    ) throws {
        log = loggerFactory.createForClass(NodeJsAppApiImpl.self)

        let idGen = RequestIdGenerator(
            localHost: LOCAL_HOST,
            localPort: NODE_JS_PROCESS_LOCAL_PORT
        )
        resultCallbacks = try ResultCallbacks(
            requestTimeoutMillis: config.getInt64(ConfigProperty.nodeJsAppApiRequestTimeoutMillis),
            scheduler: scheduler
        )
        let cmdProc = CommandProcessor(
            loggerFactory: loggerFactory, resultCallbacks: resultCallbacks)

        remoteProcessConnection = try RemoteHost(
            requestIdGenerator: idGen,
            resultCallbacks: resultCallbacks,
            host: LOCAL_HOST,
            port: NODE_JS_PROCESS_PORT,
            sendTimeoutMillis: config.getInt64(ConfigProperty.nodeJsAppApiSendTimeoutMillis),
            sendIntervalMillis: config.getInt64(ConfigProperty.nodeJsAppApiSendIntervalMillis),
            scheduler: scheduler,
            listener: cmdProc
        )

        process = try NodeJsProcess(
            jsFile: "Resources/NodeJsAppProcess",
            module: Bundle.module,
            nodeJsBinaryPath: config.getString(ConfigProperty.nodeJsBinaryPath)
        )
    }

    func start() async {
        await process.start()
    }

    func setApp(_ request: NodeJsSetAppRequest) async throws -> NodeJsSetAppResponse {
        let result = await remoteProcessConnection.request(
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
        let result = await remoteProcessConnection.request(
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
        let result = await remoteProcessConnection.request(
            cmd: NodeJsCommands.ENTITY_FUNC.rawValue, payload: jsonEncoder.encode(request))

        if let resultData = result.data {
            return try jsonDecoder.decode(NodeJsEntityFuncResponse.self, resultData)
        }

        if let resultError = result.error {
            throw AppserverError.NodeJsApp("entityFunc failed with error type=\(resultError)")
        }

        throw AppserverError.NodeJsApp("entityFunc failed in an unexpected case")
    }

    func statelessFunc(_ request: NodeJsFuncRequest) async throws
        -> NodeJsStatelessFuncResponse
    {
        let result = await remoteProcessConnection.request(
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

    func shutdown() async {
        await resultCallbacks.shutdown()
        do {
            try await remoteProcessConnection.shutdown()
        } catch {
            log.log(.ERROR, "Error shutting down remote process connection", error)
        }
    }

    func shutdownProcess() {
        process.shutdown()
    }
}
