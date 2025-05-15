struct ConsoleLogger: Logger {
    private let name: String

    init(
        name: String
    ) {
        self.name = name
    }

    func isLevel(_ logLevel: LogLevel) -> Bool {
        true
    }

    func log(_ logLevel: LogLevel, _ message: String, _ err: (any Error)?) {
        print("\(logLevel): \(name): \(message)")
        if let err {
            print(err)
        }
    }
}
