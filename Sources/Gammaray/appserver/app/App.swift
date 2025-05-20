struct App {
    private let statelessFunctions: StatelessFunctions
    private let appEntities: AppEntities
    private let lists: Lists

    init(
        statelessFunctions: StatelessFunctions,
        appEntities: AppEntities,
        lists: Lists
    ) {
        self.statelessFunctions = statelessFunctions
        self.appEntities = appEntities
        self.lists = lists
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
        await lists.scheduledTasks()
    }
}
