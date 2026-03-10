struct App {
    private let statelessFunctions: StatelessFunctions
    private let appEntities: AppEntities

    let appDescription: AppDescription

    init(
        statelessFunctions: StatelessFunctions,
        appEntities: AppEntities,
        appDescription: AppDescription,
    ) {
        self.statelessFunctions = statelessFunctions
        self.appEntities = appEntities
        self.appDescription = appDescription
    }

    func handleFunc(params: FunctionParams, entityParams: EntityParams?) async {
        if let entityParams {
            await appEntities.invoke(params: params, entityParams: entityParams)
            return
        }

        await statelessFunctions.invoke(params)
    }

    func scheduledTasks() async {
        await appEntities.scheduledTasks()
    }

    func shutdown() async {
        await appEntities.shutdown()
    }
}
