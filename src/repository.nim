import httpClient
import json
import models

type
  SlackRepository* = ref object
    url*: string

proc post*(self: SlackRepository, body: seq[Post]): string =
  var client = newHttpClient()
  let request = Payload(attachments: body)
  let response = client.request(self.url, httpMethod = HttpPost, body = $ %*request)

  return response.body
