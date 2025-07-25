import { EntityId, FuncContext, JsonObject, ResponseSender } from "../api/core"
import { HttpResponseData } from "../api/http"

export class FuncContextImpl implements FuncContext {
    constructor(
        private readonly responseSender: ResponseSender,
        readonly requestId?: string,
        readonly requestingUserId?: EntityId,
    ) {
    }

    sendResponse(body: JsonObject, httpData?: HttpResponseData): void {
        if (this.requestId) {
            this.responseSender.send(this.requestId, body, httpData)
        }
    }
}
