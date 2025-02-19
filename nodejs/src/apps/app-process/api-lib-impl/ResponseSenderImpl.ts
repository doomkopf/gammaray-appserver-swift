import { JsonObject, ResponseSender } from "../api/core"
import { NodeJsResponseSenderSend } from "../command-handlers/dtos"

export class ResponseSenderImpl implements ResponseSender {
    private response: NodeJsResponseSenderSend | null = null

    send(requestId: string, obj: JsonObject): void {
        this.response = { requestId, objJson: JSON.stringify(obj) }
    }

    getAndRemoveResponse(): NodeJsResponseSenderSend | null {
        const r = this.response
        this.response = null
        return r
    }
}
