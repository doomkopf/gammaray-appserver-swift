import { EntityId, JsonObject } from "../api/core"
import { ListFunctions } from "../api/list"
import { NodeJsListAdd, NodeJsListClear, NodeJsListIterate, NodeJsListRemove } from "../command-handlers/dtos"
import { CopyAndClearList } from "./CopyAndClearList"

export class ListFunctionsImpl implements ListFunctions {
    readonly adds = new CopyAndClearList<NodeJsListAdd>()
    readonly clears = new CopyAndClearList<NodeJsListClear>()
    readonly iterates = new CopyAndClearList<NodeJsListIterate>()
    readonly removes = new CopyAndClearList<NodeJsListRemove>()

    add(listId: EntityId, elemToAdd: string): void {
        this.adds.add({
            listId,
            elemToAdd,
        })
    }

    clear(listId: EntityId): void {
        this.clears.add({ listId })
    }

    iterate(listId: EntityId, iterationFunctionId: string, iterationFinishedFunctionId: string, customCtx?: JsonObject): void {
        this.iterates.add({
            listId,
            iterationFunctionId,
            iterationFinishedFunctionId,
            customCtxJson: !!customCtx ? JSON.stringify(customCtx) : undefined
        })
    }

    remove(listId: EntityId, elemToRemove: string): void {
        this.removes.add({
            listId,
            elemToRemove,
        })
    }
}
