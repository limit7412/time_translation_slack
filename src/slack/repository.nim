import httpClient
import json
import models

type
  SlackRepository* = ref object
    url*: string

proc sendPost(self: SlackRepository, body: Post): string =
  var client = newHttpClient()
  let response = client.request(self.url, httpMethod = HttpPost, body = $ %*body)

  return response.body

proc sendAttachments*(self: SlackRepository, body: seq[models.Attachment]): string =
  return self.sendPost(models.Post(attachments: body))
