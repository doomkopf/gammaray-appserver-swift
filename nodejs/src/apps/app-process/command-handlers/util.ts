import { AppLib } from "../AppLib";
import { NodeJsFuncResponse } from "./dtos";

export function buildNodeJsFuncResponse(lib: AppLib): NodeJsFuncResponse {
  const dto: NodeJsFuncResponse = {}

  const responseSenderPayload = lib.responseSender.getAndRemoveResponse()
  if (responseSenderPayload) {
    dto.responseSender = responseSenderPayload
  }

  dto.entityFuncInvokes = lib.entityFunc.getAndRemoveInvocations()

  return dto
}
