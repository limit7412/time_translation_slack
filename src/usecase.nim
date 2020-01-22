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
    "`" & time.intToStr & "` は変換するとこうなるよ。",
    text:
    "JST: " & jst & "\n" &
    "UTC: " & utc,
    color: "#3f93f2",
  )])

proc translationDatetime(self: TimeUsecase, date, time: string): SlackPayload =
  let
    datetime = parse(date & time,
        "yyyy-MM-ddHH:mm:ss").toTime

  return SlackPayload(attachments: @[SlackPost(
    pretext:
    "`" & date & " " & time & " (JST)` は変換するとこうなるよ。",
    text:
    "JST: " & datetime.format("yyyy-MM-dd HH:mm:ss") & "\n" &
    "UTC: " & (datetime - 9.hours).format("yyyy-MM-dd HH:mm:ss") & "\n" &
    "unixtime: " & $(datetime.toUnix),
    color: "#3f93f2",
  ), SlackPost(
    pretext:
    "`" & date & " " & time & " (UTC)` は変換するとこうなるよ。",
    text:
    "JST: " & (datetime + 9.hours).format("yyyy-MM-dd HH:mm:ss") & "\n" &
    "UTC: " & datetime.format("yyyy-MM-dd HH:mm:ss") & "\n" &
    "unixtime: " & $(datetime.toUnix),
    color: "#3f93f2",
  )])

proc translationDatetime(self: TimeUsecase, date, time,
    location: string): SlackPayload =
  let inputDatetime = parse(date & time, "yyyy-MM-ddHH:mm:ss").toTime

  let jstDatetime =
    if location == "JST":
      inputDatetime
    else:
      inputDatetime + 9.hours

  let utcDatetime =
    if location == "JST":
      inputDatetime - 9.hours
    else:
      inputDatetime

  return SlackPayload(attachments: @[SlackPost(
    pretext:
    "`" & date & " " & time & " (" & location &
    ")` は変換するとこうなるよ。",
    text:
    "JST: " & jstDatetime.format("yyyy-MM-dd HH:mm:ss") & "\n" &
    "UTC: " & utcDatetime.format("yyyy-MM-dd HH:mm:ss") & "\n" &
    "unixtime: " & $utcDatetime.toUnix,
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
    let datetime = time.split("+")
    case datetime.len
    of 2:
      self.translationDatetime(datetime[0], datetime[1].replace("%3A", ":"))
    of 3:
      self.translationDatetime(datetime[0], datetime[1].replace("%3A", ":"),
          datetime[2])
    else:
      SlackPayload(attachments: @[SlackPost(
          pretext: "日時の書式が間違ってるみたい…よく確認してみて。",
          text: "/time2unix [unixtime|yyyy-MM-dd HH:mm:ss [JST|UTC]]",
          color: "#ffca4f",
        )])

proc err*(self: TimeUsecase, err: ref Exception, time: string) =
  let
    repo = SlackRepository(url: os.getEnv("ALERT_WEBHOOK_URL").string)
    message = "エラーみたい…確認してみよっか"

  discard repo.post(@[SlackPost(
      fallback: message,
      pretext: "<@" & os.getEnv("SLACK_ID").string & "> " & message,
      title: err.msg,
      text: "input: " & time,
      color: "#EB4646",
      footer: "slack-time-translation",
    )])
