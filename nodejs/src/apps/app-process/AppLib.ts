import { EntityFunctionsImpl } from "./api-lib-impl/EntityFunctionsImpl"
import { HttpClientImpl } from "./api-lib-impl/HttpClientImpl"
import { LoggerImpl } from "./api-lib-impl/LoggerImpl"
import { ResponseSenderImpl } from "./api-lib-impl/ResponseSenderImpl"
import { UserFunctionsImpl } from "./api-lib-impl/UserFunctionsImpl"
import { Lib } from "./api/lib"
import { Tools } from "./api/tools"

export class AppLib implements Lib {
    constructor(
        readonly responseSender: ResponseSenderImpl,
        readonly user: UserFunctionsImpl,
        readonly tools: Tools,
        readonly entityFunc: EntityFunctionsImpl,
        readonly httpClient: HttpClientImpl,
        readonly log: LoggerImpl,
    ) {
    }
}
