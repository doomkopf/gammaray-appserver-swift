struct LoggerFactory {
    func createLogger(_ name: String) -> Logger {
        ConsoleLogger(name: name)
    }

    func createForClass(_ clazz: AnyObject) -> Logger {
        createLogger(String(describing: clazz))
    }
}
