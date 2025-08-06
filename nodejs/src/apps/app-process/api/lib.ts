import { EntityFunctions, ResponseSender } from "./core"
import { HttpClient } from "./http"
import { Logger } from "./log"
import { Tools } from "./tools"
import { UserFunctions } from "./user"

/**
 * A lib of all components that can be used in a function.
 */
export interface Lib {
    readonly responseSender: ResponseSender
    readonly user: UserFunctions
    readonly tools: Tools
    readonly entityFunc: EntityFunctions
    readonly httpClient: HttpClient
    readonly log: Logger
}
