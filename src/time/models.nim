import times
import  ../slack/models as slack

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

proc toSlackPost*(self: Times, pretext, color: string): slack.Post =
  return slack.Post(
    pretext: pretext,
    text:
    "JST: " & self.jstDate & "\n" &
    "UTC: " & self.utcDate & "\n" &
    "unixtime: " & $self.unixtime,
    color: color,
  )