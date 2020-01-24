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
      var
        user: string
        team: string
      for item in body.split("&"):
        let tmp = item.split("=")
        case tmp[0]
        of "user_name":
          user = tmp[1]
        of "team_domain":
          team = tmp[1]
      uc.err(getCurrentException(), "input: " & time & "\n" & "user: " & user &
          "\n" & "team: " & team)
      raise
