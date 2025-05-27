actor LibFactory {
    private var responseSender: ApiResponseSender?
    private var user: ApiUserFunctions?
    private var entityFunc: ApiEntityFunctions?
    private var httpClient: ApiHttpClient?
    private var log: ApiLogger?

    func lateBind(
        responseSender: ApiResponseSender,
        user: ApiUserFunctions,
        entityFunc: ApiEntityFunctions,
        httpClient: ApiHttpClient,
        log: ApiLogger
    ) {
        self.responseSender = responseSender
        self.user = user
        self.entityFunc = entityFunc
        self.httpClient = httpClient
        self.log = log
    }

    func create() throws -> Lib {
        if let responseSender,
            let user,
            let entityFunc,
            let httpClient,
            let log
        {
            return Lib(
                responseSender: responseSender,
                user: user,
                entityFunc: entityFunc,
                httpClient: httpClient,
                log: log
            )
        }

        throw AppserverError.General("LibFactory not initialized")
    }
}
