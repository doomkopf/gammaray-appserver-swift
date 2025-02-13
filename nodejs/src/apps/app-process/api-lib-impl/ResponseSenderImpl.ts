import { JsonObject, ResponseSender } from "../api/core"
import { NodeJsResponseSenderPayload } from "../command-handlers/dtos"

export class ResponseSenderImpl implements ResponseSender {
  private response: NodeJsResponseSenderPayload | null = null

  send(requestId: string, obj: JsonObject): void {
    this.response = { requestId, objJson: JSON.stringify(obj) }
  }

  getAndRemoveResponse(): NodeJsResponseSenderPayload | null {
    const r = this.response
    this.response = null
    return r
  }
}
