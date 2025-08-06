import { CommandContext } from "../../../lib/communication/CommandContext"
import { LogLevel } from "../../../lib/logging/LogLevel"
import { RequestContextImpl } from "../api-lib-impl/RequestContextImpl"
import { AppCommandHandler } from "../AppCommandHandler"
import { NodeJsEntityAction, NodeJsEntityFuncRequest, NodeJsEntityFuncResponse } from "./dtos"
import { buildNodeJsFuncResponse } from "./util"

export class EntityFuncCommandHandler extends AppCommandHandler {
    handleAppCommand(payload: NodeJsEntityFuncRequest, ctx?: CommandContext): void {
        const app = this.apps.getApp(payload.funcRequest.appId)
        if (!app) {
            return
        }

        const entityType = app.entity[payload.type]

        let entity = null
        if (payload.entityJson) {
            entity = JSON.parse(payload.entityJson)
            if (entityType.deserializeEntity) {
                entity = entityType.deserializeEntity(payload.id, entity)
            }
        }

        const entityFunc = entityType.func[payload.funcRequest.fun]

        let result: unknown
        try {
            result = entityFunc.func(
                entity,
                payload.id,
                this.lib,
                (payload.funcRequest.paramsJson ? JSON.parse(payload.funcRequest.paramsJson) : null) as never,
                new RequestContextImpl(
                    this.lib.responseSender,
                    payload.funcRequest.requestId,
                    payload.funcRequest.requestingUserId,
                    payload.funcRequest.clientRequestId,
                ),
            )
        } catch (err) {
            this.log.log(LogLevel.ERROR, "", err)
        }

        const response: NodeJsEntityFuncResponse = {
            general: buildNodeJsFuncResponse(this.lib),
            action: NodeJsEntityAction.NONE,
        }

        if (typeof (result) === "object") {
            response.action = NodeJsEntityAction.SET_ENTITY
            response.entityJson = JSON.stringify(result)
        } else if (result === "delete") {
            response.action = NodeJsEntityAction.DELETE_ENTITY
        }

        ctx?.respond(JSON.stringify(response))
    }
}
