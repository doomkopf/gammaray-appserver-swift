import { BigObjects } from "../api/bigobjects"
import { JsonObject } from "../api/core"

export class BigObjectsImpl implements BigObjects {
    private readonly map = new Map<string, JsonObject>()

    putObject(id: string, obj: JsonObject): void {
        this.map.set(id, obj)
    }

    getObject(id: string): JsonObject | undefined {
        return this.map.get(id)
    }
}
