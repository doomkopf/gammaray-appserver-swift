import { EntityId } from "../api/core"
import { Tools } from "../api/tools"
import { hashMD5 } from "../lib/crypto"
import { isEntityIdValid } from "../lib/tools"
import { generateUuid, nameBasedUuid } from "../lib/uuid"

export class ToolsImpl implements Tools
{
  currentTimeMillis(): number
  {
    return Date.now()
  }

  generateEntityId(): EntityId
  {
    return generateUuid()
  }

  hashMD5(str: string): string
  {
    return hashMD5(str)
  }

  isValidEntityId(id: string): boolean
  {
    return isEntityIdValid(id)
  }

  nameBasedUUID(name: string): string
  {
    return nameBasedUuid(name)
  }

  randomUUID(): string
  {
    return generateUuid()
  }
}
