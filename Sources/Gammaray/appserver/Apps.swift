actor Apps {
    private let log: Logger
    private let db: AppserverDatabase
    private let appFactory: AppFactory
    private let appsTask: ScheduledTask

    private var apps: [String: App] = [:]

    init(
        loggerFactory: LoggerFactory,
        config: Config,
        scheduler: Scheduler,
        db: AppserverDatabase,
        appFactory: AppFactory
    ) {
        log = loggerFactory.createForClass(Apps.self)

        self.appFactory = appFactory
        self.db = db

        appsTask = scheduler.scheduleInterval(
            millis: config.getInt64(ConfigProperty.appScheduledTasksIntervalMillis))
        appsTask.setFuncNotAwaiting {
            await self.scheduledTasks()
        }
    }

    private func scheduledTasks() async {
        for app in apps.values {
            await app.scheduledTasks()
        }
    }

    func handleFunc(appId: String, params: FunctionParams, entityParams: EntityParams?) async {
        let app: App
        if let loadedApp = apps[appId] {
            app = loadedApp
        } else {
            do {
                if let createdApp = try await appFactory.create(appId) {
                    if let meanWhileCreatedApp = apps[appId] {
                        app = meanWhileCreatedApp
                    } else {
                        apps[appId] = createdApp
                        app = createdApp
                    }
                } else {
                    log.log(.INFO, "App not found for id=\(appId)", nil)
                    return
                }
            } catch {
                log.log(.ERROR, "Error creating app for id=\(appId)", error)
                return
            }
        }

        await app.handleFunc(params: params, entityParams: entityParams)
    }

    func deployNodeJsApp(appId: String, code: String) async {
        await db.putApp(appId: appId, app: DatabaseApp(type: .NODEJS, code: code))
        apps.removeValue(forKey: appId)
    }

    func shutdown() async {
        await appsTask.cancel()

        for app in apps {
            await app.value.shutdown()
        }
    }
}
