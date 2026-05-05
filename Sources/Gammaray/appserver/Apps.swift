actor Apps {
    private let log: Logger
    private let db: AppserverDatabase
    private let appFactory: AppFactory
    private let appsTask: ScheduledTask

    private var apps: [AppId: App]
    private var appsInMaintenance = Set<AppId>()

    init(
        loggerFactory: LoggerFactory,
        config: Config,
        scheduler: Scheduler,
        db: AppserverDatabase,
        appFactory: AppFactory,
        staticApps: [AppId: App],
    ) {
        log = loggerFactory.createForClass(Apps.self)

        self.appFactory = appFactory
        self.db = db

        apps = staticApps

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

    func handleFunc(appId: AppId, params: FunctionParams, entityParams: EntityParams?) async {
        if isAppInMaintenance(appId: appId) {
            return
        }

        let app: App
        if let loadedApp = apps[appId] {
            app = loadedApp
        } else {
            do {
                if let createdApp = try await appFactory.create(appId) {
                    // re-check after returning to actor consistency boundary (await)
                    if isAppInMaintenance(appId: appId) {
                        return
                    }

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

        if !app.appDescription.isFunctionPublic(params: params, entityParams: entityParams) {
            return
        }

        await app.handleFunc(params: params, entityParams: entityParams)
    }

    func enableAppMaintenance(appId: AppId) {
        appsInMaintenance.insert(appId)
    }

    func disableAppMaintenance(appId: AppId) {
        appsInMaintenance.remove(appId)
    }

    private func isAppInMaintenance(appId: AppId) -> Bool {
        appsInMaintenance.contains(appId)
    }

    func deployNodeJsApp(appId: AppId, code: String) async throws {
        enableAppMaintenance(appId: appId)

        if let loadedApp = apps.removeValue(forKey: appId) {
            await loadedApp.shutdown()
        }

        try await db.putApp(appId: appId, app: DatabaseApp(type: .NODEJS, code: code))

        disableAppMaintenance(appId: appId)
    }

    func shutdown() async {
        await appsTask.cancel()

        for app in apps {
            await app.value.shutdown()
        }
    }
}
