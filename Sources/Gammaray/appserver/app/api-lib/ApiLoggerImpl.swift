final class ApiLoggerImpl: ApiLogger {
    private let log: Logger
    private let appId: String

    init(
        appId: String,
        loggerFactory: LoggerFactory
    ) {
        log = loggerFactory.createForClass(ApiLoggerImpl.self)
        self.appId = appId
    }

    func log(logLevel: ApiLogLevel, message: String) {
        log.log(map(logLevel), "\(appId): \(message)", nil)
    }

    private func map(_ apiLogLevel: ApiLogLevel) -> LogLevel {
        switch apiLogLevel {
        case .ERROR: return .ERROR
        case .WARN: return .WARN
        case .INFO: return .INFO
        case .DEBUG: return .DEBUG
        }
    }
}
