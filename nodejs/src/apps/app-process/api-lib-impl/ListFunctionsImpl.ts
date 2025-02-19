import { EntityId, JsonObject } from "../api/core"
import { ListFunctions } from "../api/list"
import { NodeJsListsAdd, NodeJsListsClear, NodeJsListsIterate, NodeJsListsRemove } from "../command-handlers/dtos"
import { CopyAndClearList } from "./CopyAndClearList"

export class ListFunctionsImpl implements ListFunctions {
    readonly adds = new CopyAndClearList<NodeJsListsAdd>()
    readonly clears = new CopyAndClearList<NodeJsListsClear>()
    readonly iterates = new CopyAndClearList<NodeJsListsIterate>()
    readonly removes = new CopyAndClearList<NodeJsListsRemove>()

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
