import { EntityId, FuncContext, JsonObject, ResponseSender } from "../api/core"
import { HttpResponseData } from "../api/http"

export class FuncContextImpl implements FuncContext
{
  constructor(
    readonly persistentLocalClientId: string | null,
    readonly requestId: string | null,
    readonly requestingUserId: EntityId | null,
    private readonly responseSender: ResponseSender,
  )
  {
  }

  sendResponse(body: JsonObject, httpData?: HttpResponseData): void
  {
    if (this.requestId)
    {
      this.responseSender.send(this.requestId, body, httpData)
    }
  }
}
