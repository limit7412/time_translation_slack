import hander
import json
import usecase

when isMainModule:
  "command".hander do (event: JsonNode) -> JsonNode:
    let uc = TimeUsecase()
    try:
      let res = uc.translation()
      return %*{
        "statusCode": 200,
        "body": $ %*res,
      }
    except:
      uc.err(getCurrentException())
      raise
