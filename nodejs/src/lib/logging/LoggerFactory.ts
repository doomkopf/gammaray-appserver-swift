import { ConsoleLogger } from "./console/ConsoleLogger"
import { Logger } from "./Logger"
import { LogLevel } from "./LogLevel"

export function logLevelToString(logLevel: LogLevel): string
{
  switch (logLevel)
  {
    case LogLevel.DEBUG:
      return "DEBUG"
    case LogLevel.INFO:
    default:
      return "INFO"
    case LogLevel.WARN:
      return "WARN"
    case LogLevel.ERROR:
      return "ERROR"
  }
}

export class LoggerFactory
{
  constructor(
    private readonly logLevel: LogLevel,
  )
  {
  }

  createLogger(name: string): Logger
  {
    return new ConsoleLogger(this.logLevel, name)
  }

  createForClass(clazz: { name: string }): Logger
  {
    return this.createLogger(clazz.name)
  }
}
