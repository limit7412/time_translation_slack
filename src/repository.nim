import httpClient
import json

type
  SlackRepository* = ref object
    url*: string

type
  Post* = ref object
    fallback*: string
    pretext*: string
    title*: string
    text*: string
    color*: string
    footer*: string
type
  payload = ref object
    attachments: seq[Post]

proc post*(self: SlackRepository, body: seq[Post]): string =
  var client = newHttpClient()
  let request = payload(attachments: body)
  let response = client.request(self.url, httpMethod = HttpPost, body = $ %*request)

  return response.body
