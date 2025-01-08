final class LoggerFactory: Sendable {
    func createLogger(_ name: String) -> Logger {
        ConsoleLogger(name: name)
    }

    func createForClass(_ clazz: AnyClass) -> Logger {
        createLogger(String(describing: clazz))
    }
}
