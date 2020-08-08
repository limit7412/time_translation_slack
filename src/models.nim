import times
import strutils
import tables
import uri

type
  SlackPost* = ref object
    fallback*: string
    pretext*: string
    title*: string
    text*: string
    color*: string
    footer*: string

  SlackPayload* = ref object
    attachments*: seq[SlackPost]

type
  SlashCommand* = ref object
    input*: string
    token*: string
    teamID*: string
    teamDomain*: string
    channelID*: string
    channelName*: string
    userID*: string
    userName*: string
    command*: string
    text*: seq[string]
    responseURL*: string
    triggerID*: string

proc parseSlashCommand*(input: string): SlashCommand =
  var
    table = Table[string, string]()

  for item in input.split("\"")[1].split("&"):
    let kv = item.split("=")
    table[kv[0]] = kv[1].decodeUrl

  return SlashCommand(
      input: input,
      token: table["token"],
      teamID: table["team_id"],
      teamDomain: table["team_domain"],
      channelID: table["channel_id"],
      channelName: table["channel_name"],
      userID: table["user_id"],
      userName: table["user_name"],
      command: table["command"],
      text: table["text"].split(" "),
      responseURL: table["response_url"],
      triggerID: table["trigger_id"],
    )

type
  Times* = ref object
    unixtime*: int64
    utcDate*: string
    jstDate*: string

proc toTimes*(unixtime: int): Times =
  let
    self = Times()

  self.unixtime = unixtime

  let
    date = unixtime.fromUnix
    jstdate = date + 9.hours

  self.utcDate = date.format("yyyy-MM-dd HH:mm:ss")
  self.jstDate = jstdate.format("yyyy-MM-dd HH:mm:ss")

  return self

proc parseJST(self: Times, time: string): Times =
  let
    jstDatetime = parse(time, "yyyy-MM-ddHH:mm:ss").toTime
    utcDatetime = jstDatetime - 9.hours

  self.jstDate = jstDatetime.format("yyyy-MM-dd HH:mm:ss")
  self.utcDate = utcDatetime.format("yyyy-MM-dd HH:mm:ss")
  self.unixtime = utcDatetime.toUnix

  return self

proc parseUTC(self: Times, time: string): Times =
  let
    utcDatetime = parse(time, "yyyy-MM-ddHH:mm:ss").toTime
    jstDatetime = utcDatetime + 9.hours

  self.utcDate = utcDatetime.format("yyyy-MM-dd HH:mm:ss")
  self.jstDate = jstDatetime.format("yyyy-MM-dd HH:mm:ss")
  self.unixtime = utcDatetime.toUnix

  return self

proc toTimes*(time, timezone: string): Times =
  let
    self = Times()

  case timezone
  of "JST":
    return self.parseJST(time)
  of "UTC":
    return self.parseUTC(time)

  return self

proc toSlackPost*(self: Times, pretext, color: string): SlackPost =
  return SlackPost(
    pretext: pretext,
    text:
    "JST: " & self.jstDate & "\n" &
    "UTC: " & self.utcDate & "\n" &
    "unixtime: " & $self.unixtime,
    color: color,
  )