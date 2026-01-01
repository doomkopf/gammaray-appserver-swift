struct LoggerFactory {
    let logLevel: LogLevel

    func createLogger(_ name: String) -> Logger {
        ConsoleLogger(logLevel: logLevel, name: name)
    }

    func createForClass(_ clazz: AnyObject) -> Logger {
        createLogger(String(describing: clazz))
    }
}
