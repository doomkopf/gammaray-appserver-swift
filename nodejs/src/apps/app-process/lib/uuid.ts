import { v4 } from "uuid"
import getUuid from "uuid-by-string"

export function generateUuid(): string {
    return v4()
}

export function nameBasedUuid(name: string): string {
    return getUuid(name)
}
