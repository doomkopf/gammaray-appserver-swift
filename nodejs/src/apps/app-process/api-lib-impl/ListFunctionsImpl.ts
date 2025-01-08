import { EntityId, FuncContext, JsonObject } from "../api/core"
import { ListFunctions } from "../api/list"

export class ListFunctionsImpl implements ListFunctions
{
  add(listId: EntityId, elemToAdd: string): void
  {
  }

  clear(listId: EntityId): void
  {
  }

  iterate(listId: EntityId, iterationFunctionId: string, iterationFinishedFunctionId: string, ctx: FuncContext, customCtx?: JsonObject): void
  {
  }

  remove(listId: EntityId, elemToRemove: string): void
  {
  }
}
