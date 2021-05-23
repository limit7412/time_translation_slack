import json

import runtime/lambda
import slack/models as slack
import time/usecase as timeUC
import error/usecase as errUC

when isMainModule:
  "command".hander do (event: JsonNode) -> JsonNode:
    let
      timeUsecase = timeUC.TimeUsecase()
      errUsecase = errUC.ErrorUsecase()

    try:
      let
        slashCommand = ($event["body"])
          .parseSlashCommand()
        res = timeUsecase.translation(slashCommand)
      return %*{
        "statusCode": 200,
        "body": $ %*res,
      }
    except:
      errUsecase.alert(getCurrentException())
      raise
