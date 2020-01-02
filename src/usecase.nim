import os
import repository

type
  TimeUsecase* = ref object

proc translation*(self: TimeUsecase): Post =
  return Post(
      text: "test"
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
