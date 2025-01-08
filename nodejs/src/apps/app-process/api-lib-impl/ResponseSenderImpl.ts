import { JsonObject, ResponseSender } from "../api/core"
import { ResponseSenderPayload } from "../command-handlers/dtos"

export class ResponseSenderImpl implements ResponseSender {
  private response: ResponseSenderPayload | null = null

  send(requestId: string, obj: JsonObject): void {
    this.response = { requestId, objJson: JSON.stringify(obj) }
  }

  getAndRemoveResponse(): ResponseSenderPayload | null {
    const r = this.response
    this.response = null
    return r
  }
}
