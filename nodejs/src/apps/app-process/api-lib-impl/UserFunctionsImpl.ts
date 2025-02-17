import { EntityId, JsonObject } from "../api/core"
import { UserFunctions } from "../api/user"
import { NodeJsUserFunctionsLogin, NodeJsUserFunctionsSendPayload } from "../command-handlers/dtos"
import { CopyAndClearList } from "./CopyAndClearList"

export class UserFunctionsImpl implements UserFunctions {
    readonly logins = new CopyAndClearList<NodeJsUserFunctionsLogin>()
    readonly logouts = new CopyAndClearList<string>()
    readonly sends = new CopyAndClearList<NodeJsUserFunctionsSendPayload>()

    login(userId: EntityId, loginFinishedFunctionId: string, customCtx?: JsonObject): void {
        this.logins.add({ userId, funcId: loginFinishedFunctionId, customCtxJson: !!customCtx ? JSON.stringify(customCtx) : undefined })
    }

    logout(userId: EntityId): void {
        this.logouts.add(userId)
    }

    send(userId: EntityId, obj: JsonObject): void {
        this.sends.add({ userId, objJson: JSON.stringify(obj) })
    }
}
