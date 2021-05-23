import os

import ../slack/models as slack
import  ../slack/repository as slackRepo

type
  ErrorUsecase* = ref object

proc err*(self: ErrorUsecase, err: ref Exception) =
  let
    repo = slackRepo.SlackRepository(url: os.getEnv("ALERT_WEBHOOK_URL").string)
    message = "エラーみたい…確認してみよっか"

  discard repo.sendPost(@[slack.Post(
      fallback: message,
      pretext: "<@" & os.getEnv("SLACK_ID").string & "> " & message,
      title: err.msg,
      text: err.getStackTrace,
      color: "#EB4646",
      footer: "slack-time-translation",
    )])
