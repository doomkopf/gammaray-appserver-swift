import { RequestContext } from "../../../lib/communication/RequestContext"
import { FuncContextImpl } from "../api-lib-impl/FuncContextImpl"
import { AppCommandHandler } from "../AppCommandHandler"
import { EntityAction, EntityFuncRequest, EntityFuncResponse } from "./dtos"
import { buildNodeJsFuncResponse } from "./util"

export class EntityFuncCommandHandler extends AppCommandHandler {
  handleAppCommand(payload: EntityFuncRequest, ctx?: RequestContext): void {
    const app = this.apps.getApp(payload.appId)
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

    const entityFunc = entityType.func[payload.efunc]

    const result = entityFunc.func(
      entity,
      payload.id,
      this.lib,
      (payload.paramsJson ? JSON.parse(payload.paramsJson) : null) as never,
      new FuncContextImpl(payload.persistentLocalClientId, payload.requestId, payload.requestingUserId, this.lib.responseSender),
    )

    const response: EntityFuncResponse = {
      general: buildNodeJsFuncResponse(this.lib),
      action: EntityAction.NONE
    }

    if (typeof (result) === "object") {
      response.action = EntityAction.SET_ENTITY
      response.entityJson = JSON.stringify(result)
    } else if (result === "delete") {
      response.action = EntityAction.DELETE_ENTITY
    }

    ctx?.respond(JSON.stringify(response))
  }
}
