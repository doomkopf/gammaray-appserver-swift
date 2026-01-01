struct ConsoleLogger: Logger {
    private let logLevel: LogLevel
    private let name: String

    init(
        logLevel: LogLevel,
        name: String,
    ) {
        self.logLevel = logLevel
        self.name = name
    }

    func isLevel(_ logLevel: LogLevel) -> Bool {
        logLevel.rawValue <= self.logLevel.rawValue
    }

    func log(_ logLevel: LogLevel, _ message: String, _ err: (any Error)?) {
        guard isLevel(logLevel) else {
            return
        }

        print("\(logLevel): \(name): \(message)")
        if let err {
            print(err)
        }
    }
}
