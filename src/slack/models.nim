import strutils
import tables
import uri

type
  Attachment* = ref object
    fallback*: string
    pretext*: string
    title*: string
    text*: string
    color*: string
    footer*: string

  Post* = ref object
    attachments*: seq[Attachment]

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
