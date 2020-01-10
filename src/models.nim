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
