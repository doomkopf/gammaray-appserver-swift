import { EntityId, FuncContext, JsonObject } from "../api/core"
import { UserFunctions } from "../api/user"

export class UserFunctionsImpl implements UserFunctions
{
  login(userId: EntityId, loginFinishedFunctionId: string, ctx: FuncContext, customCtx?: JsonObject): void
  {
  }

  logout(userId: EntityId): void
  {
  }

  send(userId: EntityId, obj: JsonObject): void
  {
  }
}
