import hander
import json

import usecase
import models

when isMainModule:
  "command".hander do (event: JsonNode) -> JsonNode:
    let
      uc = TimeUsecase()

    try:
      let
        slashCommand = ($event["body"])
          .parseSlashCommand()
        res = uc.translation(slashCommand)
      return %*{
        "statusCode": 200,
        "body": $ %*res,
      }
    except:
      uc.err(getCurrentException())
      raise
