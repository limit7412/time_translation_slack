import hander
import json
import strutils
from sequtils import filter

import usecase

when isMainModule:
  "command".hander do (event: JsonNode) -> JsonNode:
    let uc = TimeUsecase()
    let body = $event["body"]
    let text = body.split("&").filter do (item: string) -> bool:
      let tmp = item.split("=")
      return tmp[0] == "text"
    let time = text[0].split("=")[1]
    try:
      let res = uc.translation(time)
      return %*{
        "statusCode": 200,
        "body": $ %*res,
      }
    except:
      uc.err(getCurrentException(), time)
      raise
