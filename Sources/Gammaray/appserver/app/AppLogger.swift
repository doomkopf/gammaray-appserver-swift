final class AppLogger: Sendable {
    private let log: Logger
    private let appId: String

    init(
        appId: String,
        loggerFactory: LoggerFactory
    ) {
        log = loggerFactory.createForClass(AppLogger.self)
        self.appId = appId
    }

    func log(logLevel: LogLevel, message: String) {
        log.log(logLevel, "\(appId): \(message)", nil)
    }
}
