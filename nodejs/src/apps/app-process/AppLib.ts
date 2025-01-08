import { BigObjectsImpl } from "./api-lib-impl/BigObjectsImpl"
import { EntityFunctionsImpl } from "./api-lib-impl/EntityFunctionsImpl"
import { ResponseSenderImpl } from "./api-lib-impl/ResponseSenderImpl"
import { HttpClient } from "./api/http"
import { Lib } from "./api/lib"
import { ListFunctions } from "./api/list"
import { Logger } from "./api/log"
import { EntityQueries } from "./api/query"
import { Tools } from "./api/tools"
import { UserFunctions } from "./api/user"

export class AppLib implements Lib
{
  constructor(
    readonly responseSender: ResponseSenderImpl,
    readonly user: UserFunctions,
    readonly tools: Tools,
    readonly entityFunc: EntityFunctionsImpl,
    readonly listFunc: ListFunctions,
    readonly entityQueries: EntityQueries,
    readonly httpClient: HttpClient,
    readonly log: Logger,
    readonly bigObjects: BigObjectsImpl,
  )
  {
  }
}
