import httpClient
import json
import models

type
  SlackRepository* = ref object
    url*: string

  payload = ref object
    attachments: seq[Post]

proc post*(self: SlackRepository, body: seq[Post]): string =
  var client = newHttpClient()
  let request = payload(attachments: body)
  let response = client.request(self.url, httpMethod = HttpPost, body = $ %*request)

  return response.body
