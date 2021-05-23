import httpClient
import json
import models

type
  SlackRepository* = ref object
    url*: string

proc sendPost*(self: SlackRepository, body: seq[models.Post]): string =
  var client = newHttpClient()
  let request = models.Payload(attachments: body)
  let response = client.request(self.url, httpMethod = HttpPost, body = $ %*request)

  return response.body
