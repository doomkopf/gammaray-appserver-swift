import { EntityId, FuncContext, JsonObject } from "../api/core"
import { ListFunctions } from "../api/list"

export class ListFunctionsImpl implements ListFunctions {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    add(listId: EntityId, elemToAdd: string): void {
    }

    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    clear(listId: EntityId): void {
    }

    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    iterate(listId: EntityId, iterationFunctionId: string, iterationFinishedFunctionId: string, ctx: FuncContext, customCtx?: JsonObject): void {
    }

    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    remove(listId: EntityId, elemToRemove: string): void {
    }
}
