import { JsonObject } from "../api/core"
import { EntityQueries, EntityQuery, EntityQueryAttributeValue } from "../api/query"
import { NodeJsEntityQueryAttributeValue, NodeJsEntityQueryInvokePayload } from "../command-handlers/dtos"
import { CopyAndClearList } from "./CopyAndClearList"

export class EntityQueriesImpl implements EntityQueries {
    readonly invocations = new CopyAndClearList<NodeJsEntityQueryInvokePayload>()

    query(entityType: string, queryFinishedFunctionId: string, query: EntityQuery, customCtx?: JsonObject): void {
        this.invocations.add({
            entityType,
            queryFinishedFunctionId,
            query: {
                attributes: query.attributes.map(attr => {
                    return {
                        name: attr.name,
                        value: this.mapEntityQueryAttributeValue(attr.value),
                    }
                })
            },
            customCtxJson: !!customCtx ? JSON.stringify(customCtx) : undefined,
        })
    }

    private mapEntityQueryAttributeValue(value: EntityQueryAttributeValue): NodeJsEntityQueryAttributeValue {
        return {
            match: value.match !== undefined ? String(value.match) : undefined,
            range: value.range,
        }
    }
}
