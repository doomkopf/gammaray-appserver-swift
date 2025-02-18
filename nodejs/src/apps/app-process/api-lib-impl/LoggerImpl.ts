import { Logger, LogLevel } from "../api/log";
import { NodeJsLog, NodeJsLogLevel } from "../command-handlers/dtos";
import { CopyAndClearList } from "./CopyAndClearList";

export class LoggerImpl implements Logger {
    readonly logs = new CopyAndClearList<NodeJsLog>()

    log(logLevel: LogLevel, message: string): void {
        this.logs.add({
            logLevel: this.mapLogLevel(logLevel),
            message,
        })
    }

    private mapLogLevel(level: LogLevel): NodeJsLogLevel {
        switch (level) {
            case LogLevel.ERROR:
                return NodeJsLogLevel.ERROR
            case LogLevel.WARN:
                return NodeJsLogLevel.WARN
            case LogLevel.INFO:
                return NodeJsLogLevel.INFO
            case LogLevel.DEBUG:
                return NodeJsLogLevel.DEBUG
        }
    }
}
