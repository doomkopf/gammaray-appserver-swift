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
                try {
                    entity = entityType.deserializeEntity(payload.id, entity)
                } catch (err) {
                    this.log.log(LogLevel.ERROR, "Error deserializing entity - id: " + payload.id, err)
                    this.respondDefault()
                    return
                }
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
            this.log.log(LogLevel.ERROR, "Error in entity func: " + payload.type + "." + payload.funcRequest.fun, err)
        }

        const response: NodeJsEntityFuncResponse = {
            general: buildNodeJsFuncResponse(this.lib),
            action: NodeJsEntityAction.NONE,
        }

        if (typeof (result) === "object") {
            if (entityType.serializeEntity) {
                try {
                    result = entityType.serializeEntity(payload.id, result)
                } catch (err) {
                    this.log.log(LogLevel.ERROR, "Error serializing entity - id: " + payload.id, err)
                    this.respondDefault()
                    return
                }
            }
            response.action = NodeJsEntityAction.SET_ENTITY
            response.entityJson = JSON.stringify(result)
        } else if (result === "delete") {
            response.action = NodeJsEntityAction.DELETE_ENTITY
        }

        ctx?.respond(JSON.stringify(response))
    }

    private respondDefault(ctx?: CommandContext) {
        if (ctx) {
            const response: NodeJsEntityFuncResponse = {
                general: buildNodeJsFuncResponse(this.lib),
                action: NodeJsEntityAction.NONE,
            }
            ctx.respond(JSON.stringify(response))
        }
    }
}
