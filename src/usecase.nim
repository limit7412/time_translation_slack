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

proc translationDatetime(self: TimeUsecase, date, time: string): SlackPayload =
  let
    datetime = parse(date & time,
        "yyyy-MM-ddHH:mm:ss").toTime

  return SlackPayload(attachments: @[SlackPost(
    pretext:
    "`" & date & " " & time & "` はもしJSTならUTCとunixtimeはこうで、",
    text:
    "JST: " & datetime.format("yyyy-MM-dd HH:mm:ss") & "\n" &
    "UTC: " & (datetime - 9.hours).format("yyyy-MM-dd HH:mm:ss") & "\n" &
    "unixtime: " & $(datetime.toUnix),
    color: "#3f93f2",
  ), SlackPost(
    pretext:
    "もしUTCならJSTとunixtimeはこうだよ。",
    text:
    "JST: " & (datetime + 9.hours).format("yyyy-MM-dd HH:mm:ss") & "\n" &
    "UTC: " & datetime.format("yyyy-MM-dd HH:mm:ss") & "\n" &
    "unixtime: " & $(datetime.toUnix),
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
    else:
      SlackPayload(attachments: @[SlackPost(
          pretext: "日時の書式が間違ってるみたい…よく確認してみて。",
          text: "/time2unix [unixtime|yyyy-MM-dd HH:mm:ss]",
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
      color: "#EB4646",
      footer: "slack-time-translation",
    )])
