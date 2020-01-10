import os
import strutils
import times

import models
import repository

type
  TimeUsecase* = ref object

proc translationUnixtime(self: TimeUsecase, time: int): SlackPayload =
  let
    date = time.fromUnix
    jstdate = date + 9.hours
    utc = date.format("yyyy-MM-dd HH:mm:ss")
    jst = jstdate.format("yyyy-MM-dd HH:mm:ss")

  return SlackPayload(attachments: @[SlackPost(
    pretext:
    "unixtimeの `" & time.intToStr &
    "` は日本時間では `" & date.format("yyyy/MM/dd HH:mm:ss") &
    "` だよ。",
    text:
    "JST: " & jst & "\n" &
    "UTC: " & utc,
    color: "#3f93f2",
  )])

proc translation*(self: TimeUsecase, time: string): SlackPayload =
  let isUnixtime =
    try:
      discard time.parseInt
      true
    except:
      false

  if isUnixtime:
    self.translationUnixtime(time.parseInt)
  else:
    SlackPayload(attachments: @[SlackPost(text: "string")])

proc err*(self: TimeUsecase, err: ref Exception) =
  let repo = SlackRepository(url: os.getEnv("ALERT_WEBHOOK_URL").string)
  let message = "エラーみたい…確認してみよっか"
  discard repo.post(@[SlackPost(
      fallback: message,
      pretext: "<@" & os.getEnv("SLACK_ID").string & "> " & message,
      title: err.msg,
      color: "#EB4646",
      footer: "slack-time-translation",
    )])
