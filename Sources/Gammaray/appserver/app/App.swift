struct App {
    private let statelessFunctions: StatelessFunctions
    private let appEntities: AppEntities

    init(
        statelessFunctions: StatelessFunctions,
        appEntities: AppEntities
    ) {
        self.statelessFunctions = statelessFunctions
        self.appEntities = appEntities
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
}
