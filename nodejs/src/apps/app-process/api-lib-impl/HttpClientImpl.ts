import { FuncContext, JsonObject } from "../api/core"
import { HttpClient, HttpHeaders, HttpMethod } from "../api/http"

export class HttpClientImpl implements HttpClient {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    request(url: string, method: HttpMethod, body: string | null, headers: HttpHeaders, resultFunc: string, requestCtx: JsonObject | null, ctx: FuncContext): void {
    }
}
