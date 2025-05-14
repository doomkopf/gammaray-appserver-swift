actor LibFactory {
    private var responseSender: ApiResponseSender?
    private var user: ApiUserFunctions?
    private var entityFunc: ApiEntityFunctions?
    private var httpClient: ApiHttpClient?
    private var lists: ApiLists?
    private var entityQueries: ApiEntityQueries?
    private var log: ApiLogger?

    func lateBind(
        responseSender: ApiResponseSender,
        user: ApiUserFunctions,
        entityFunc: ApiEntityFunctions,
        httpClient: ApiHttpClient,
        lists: ApiLists,
        entityQueries: ApiEntityQueries,
        log: ApiLogger
    ) {
        self.responseSender = responseSender
        self.user = user
        self.entityFunc = entityFunc
        self.httpClient = httpClient
        self.lists = lists
        self.entityQueries = entityQueries
        self.log = log
    }

    func create() -> Lib? {
        if let responseSender = responseSender,
            let user = user,
            let entityFunc = entityFunc,
            let httpClient = httpClient,
            let lists = lists,
            let entityQueries = entityQueries,
            let log = log
        {
            return Lib(
                responseSender: responseSender,
                user: user,
                entityFunc: entityFunc,
                httpClient: httpClient,
                lists: lists,
                entityQueries: entityQueries,
                log: log
            )
        }

        return nil
    }
}
