import os
import strutils

import models
import repository

type
  TimeUsecase* = ref object

proc translation*(self: TimeUsecase, time: string): Post =
  var isUnixtime: bool
  try:
    discard time.parseInt
    isUnixtime = true
  except:
    isUnixtime = false

  if isUnixtime:
    return Post(
        text: "unixtime"
      )
  else:
    return Post(
        text: "string"
      )

proc err*(self: TimeUsecase, err: ref Exception) =
  let repo = SlackRepository(url: os.getEnv("ALERT_WEBHOOK_URL").string)
  let message = "エラーみたい…確認してみよっか"
  discard repo.post(@[Post(
      fallback: message,
      pretext: "<@" & os.getEnv("SLACK_ID").string & "> " & message,
      title: err.msg,
      color: "#EB4646",
      footer: "slack-izumi-suki-bot",
    )])
