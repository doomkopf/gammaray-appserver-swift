import { JsonObject } from "../api/core"
import { HttpClient, HttpHeaders, HttpMethod } from "../api/http"
import { NodeJsHttpClientRequest, NodeJsHttpMethod } from "../command-handlers/dtos"
import { CopyAndClearList } from "./CopyAndClearList"

export class HttpClientImpl implements HttpClient {
    readonly requests = new CopyAndClearList<NodeJsHttpClientRequest>()

    request(url: string, method: HttpMethod, body: string | null, headers: HttpHeaders, resultFunc: string, requestCtx: JsonObject | null): void {
        this.requests.add({
            url,
            method: this.mapHttpMethod(method),
            body: body || undefined,
            headers: headers.headers,
            resultFunc,
            requestCtxJson: !!requestCtx ? JSON.stringify(requestCtx) : undefined,
        })
    }

    private mapHttpMethod(method: HttpMethod): NodeJsHttpMethod {
        switch (method) {
            case "GET":
                return NodeJsHttpMethod.GET
            case "POST":
                return NodeJsHttpMethod.POST
            case "PUT":
                return NodeJsHttpMethod.PUT
            case "PATCH":
                return NodeJsHttpMethod.PATCH
            case "DELETE":
                return NodeJsHttpMethod.DELETE
        }
    }
}
