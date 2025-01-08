import { BigObjectsImpl } from "./api-lib-impl/BigObjectsImpl"
import { EntityFunctionsImpl } from "./api-lib-impl/EntityFunctionsImpl"
import { EntityQueriesImpl } from "./api-lib-impl/EntityQueriesImpl"
import { HttpClientImpl } from "./api-lib-impl/HttpClientImpl"
import { ListFunctionsImpl } from "./api-lib-impl/ListFunctionsImpl"
import { LoggerImpl } from "./api-lib-impl/LoggerImpl"
import { ResponseSenderImpl } from "./api-lib-impl/ResponseSenderImpl"
import { ToolsImpl } from "./api-lib-impl/ToolsImpl"
import { UserFunctionsImpl } from "./api-lib-impl/UserFunctionsImpl"
import { AppLib } from "./AppLib"
import { Apps } from "./Apps"

class AppProcess {
    private readonly apps: Apps

    constructor() {
        this.apps = new Apps(new AppLib(
            new ResponseSenderImpl(),
            new UserFunctionsImpl(),
            new ToolsImpl(),
            new EntityFunctionsImpl(),
            new ListFunctionsImpl(),
            new EntityQueriesImpl(),
            new HttpClientImpl(),
            new LoggerImpl(),
            new BigObjectsImpl(),
        ))
    }

    async shutdown() {
        await this.apps.shutdown()
    }
}

function exec() {
    const app = new AppProcess()

    process.on("SIGTERM", async () => {
        await app.shutdown()
    })
}

exec()
