import os
import httpClient
import json

proc hander*(name: string, callback: proc(e: JsonNode): JsonNode) =
  if name != os.getEnv("_HANDLER").string:
    return

  let api = os.getEnv("AWS_LAMBDA_RUNTIME_API").string
  while true:
    var nextClient = newHttpClient()
    let event = nextClient.request("http://" & api &
      "/2018-06-01/runtime/invocation/next", httpMethod = HttpGet)
    let requestId = event.headers["lambda-runtime-aws-request-id"]

    var returnUrl = "http://" & api & "/2018-06-01/runtime/invocation/" & requestId
    var resClient = newHttpClient()
    try:
      let result = callback(event.body.parseJson)
      discard resClient.postContent(returnUrl & "/response", body = $result)
    except:
      discard resClient.postContent(returnUrl & "/error", body = $ %*{
        "statusCode": 500,
        "body": $ %*{
          "msg": "Internal Lambda Error"
        },
      })
