import { FuncContext, JsonObject } from "../api/core"
import { EntityQueries, EntityQuery } from "../api/query"

export class EntityQueriesImpl implements EntityQueries
{
  query(entityType: string, queryFinishedFunctionId: string, query: EntityQuery, ctx: FuncContext, customCtx?: JsonObject): void
  {
  }
}
