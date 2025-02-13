import { EntityFunctions, EntityId, JsonObject } from "../api/core"
import { NodeJsEntityFuncInvokePayload } from "../command-handlers/dtos"
import { CopyAndClearList } from "./CopyAndClearList"

export class EntityFunctionsImpl implements EntityFunctions {
  readonly invocations = new CopyAndClearList<NodeJsEntityFuncInvokePayload>()

  invoke(entityType: string, func: string, entityId: EntityId, params: JsonObject | null): void {
    this.invocations.add({ type: entityType, _func: func, entityId, paramsJson: !!params ? JSON.stringify(params) : null })
  }
}
