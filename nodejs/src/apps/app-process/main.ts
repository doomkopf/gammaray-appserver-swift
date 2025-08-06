import { LoggerFactory } from "../../lib/logging/LoggerFactory"
import { EntityFunctionsImpl } from "./api-lib-impl/EntityFunctionsImpl"
import { HttpClientImpl } from "./api-lib-impl/HttpClientImpl"
import { LoggerImpl } from "./api-lib-impl/LoggerImpl"
import { ResponseSenderImpl } from "./api-lib-impl/ResponseSenderImpl"
import { ToolsImpl } from "./api-lib-impl/ToolsImpl"
import { UserFunctionsImpl } from "./api-lib-impl/UserFunctionsImpl"
import { LogLevel } from "./api/log"
import { AppLib } from "./AppLib"
import { Apps } from "./Apps"

class AppProcess {
    private readonly apps: Apps

    constructor() {
        this.apps = new Apps(
            new LoggerFactory(LogLevel.DEBUG),
            new AppLib(
                new ResponseSenderImpl(),
                new UserFunctionsImpl(),
                new ToolsImpl(),
                new EntityFunctionsImpl(),
                new HttpClientImpl(),
                new LoggerImpl(),
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
