protocol Logger: Sendable {
    func isLevel(_ logLevel: LogLevel) -> Bool
    func log(_ logLevel: LogLevel, _ message: String, _ err: Error?)
}
