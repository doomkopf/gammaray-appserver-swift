const ALLOWED_CHARACTERS_ENTITY_ID = /^[A-Za-z0-9-_]*$/

export function isEntityIdValid(id: string): boolean
{
  return !!id
    && id.length >= 3
    && id.length <= 128
    && ALLOWED_CHARACTERS_ENTITY_ID.test(id)
}
