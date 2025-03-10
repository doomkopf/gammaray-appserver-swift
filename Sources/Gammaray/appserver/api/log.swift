enum ApiLogLevel {
    case ERROR
    case WARN
    case INFO
    case DEBUG
}

protocol ApiLogger: Sendable {
    func log(logLevel: ApiLogLevel, message: String)
}
