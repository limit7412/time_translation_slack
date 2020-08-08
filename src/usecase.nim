import os
import strutils
import times

import models
import repository

type
  TimeUsecase* = ref object

proc translationUnixtime(self: TimeUsecase, unixtime: int): SlackPayload =
  let
    res = unixtime
      .toTimes()
      .toSlackPost("`" & unixtime.intToStr & "` は変換するとこうなるよ。", "#3f93f2")

  return SlackPayload(attachments: @[res])

proc translationDatetime(self: TimeUsecase, date, time: string): SlackPayload =
  let
    jst = (date & time)
      .toTimes("JST")
      .toSlackPost("`" & date & " " & time & " (JST)` は変換するとこうなるよ。", "#3f93f2")
    utc = (date & time)
      .toTimes("UTC")
      .toSlackPost("`" & date & " " & time & " (UTC)` は変換するとこうなるよ。", "#3f93f2")

  return SlackPayload(attachments: @[jst, utc])

proc translationDatetime(self: TimeUsecase, date, time, location: string): SlackPayload =
  let
    res = (date & time)
      .toTimes(location)
      .toSlackPost("`" & date & " " & time & " (" & location & ")` は変換するとこうなるよ。", "#3f93f2")

  return SlackPayload(attachments: @[res])

proc translation*(self: TimeUsecase, slashCommand: SlashCommand): SlackPayload =
  let isUnixtime =
    try:
      discard slashCommand.text[0].parseInt
      true
    except:
      false

  if isUnixtime:
    self.translationUnixtime(slashCommand.text[0].parseInt)
  else:
    let
      date = slashCommand.text[0]
      time = slashCommand.text[1]

    try:
      discard (date & " " & time).parse("yyyy-MM-dd HH:mm:ss")
    except:
      return SlackPayload(attachments: @[SlackPost(
        pretext: "日時の書式が間違ってるみたい…よく確認してみて。",
        text: "/time2unix [unixtime|yyyy-MM-dd HH:mm:ss [JST|UTC]]",
        color: "#ffca4f",
      )])

    case slashCommand.text.len
    of 2:
      self.translationDatetime(date, time)
    of 3:
      self.translationDatetime(date, time, slashCommand.text[2])
    else:
      SlackPayload(attachments: @[SlackPost(
          pretext: "引数の数が間違ってるみたい…よく確認してみて。",
          text: "/time2unix [unixtime|yyyy-MM-dd HH:mm:ss [JST|UTC]]",
          color: "#ffca4f",
        )])

proc err*(self: TimeUsecase, err: ref Exception) =
  let
    repo = SlackRepository(url: os.getEnv("ALERT_WEBHOOK_URL").string)
    message = "エラーみたい…確認してみよっか"

  discard repo.post(@[SlackPost(
      fallback: message,
      pretext: "<@" & os.getEnv("SLACK_ID").string & "> " & message,
      title: err.msg,
      text: err.getStackTrace,
      color: "#EB4646",
      footer: "slack-time-translation",
    )])
