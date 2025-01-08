import { EntityFunctions, EntityId, JsonObject } from "../api/core"
import { EntityFuncInvokePayload } from "../command-handlers/dtos"

export class EntityFunctionsImpl implements EntityFunctions {
  private invocations: EntityFuncInvokePayload[] = []

  invoke(entityType: string, func: string, entityId: EntityId, params: JsonObject | null): void {
    this.invocations.push({ type: entityType, _func: func, entityId, paramsJson: !!params ? JSON.stringify(params) : null })
  }

  getAndRemoveInvocations(): EntityFuncInvokePayload[] {
    const i = this.invocations
    this.invocations = []
    return i
  }
}
