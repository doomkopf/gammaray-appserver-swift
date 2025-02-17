import { BigObjectsImpl } from "./api-lib-impl/BigObjectsImpl"
import { EntityFunctionsImpl } from "./api-lib-impl/EntityFunctionsImpl"
import { EntityQueriesImpl } from "./api-lib-impl/EntityQueriesImpl"
import { ResponseSenderImpl } from "./api-lib-impl/ResponseSenderImpl"
import { UserFunctionsImpl } from "./api-lib-impl/UserFunctionsImpl"
import { HttpClient } from "./api/http"
import { Lib } from "./api/lib"
import { ListFunctions } from "./api/list"
import { Logger } from "./api/log"
import { Tools } from "./api/tools"

export class AppLib implements Lib {
    constructor(
        readonly responseSender: ResponseSenderImpl,
        readonly user: UserFunctionsImpl,
        readonly tools: Tools,
        readonly entityFunc: EntityFunctionsImpl,
        readonly listFunc: ListFunctions,
        readonly entityQueries: EntityQueriesImpl,
        readonly httpClient: HttpClient,
        readonly log: Logger,
        readonly bigObjects: BigObjectsImpl,
    ) {
    }
}
