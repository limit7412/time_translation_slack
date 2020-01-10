type
  Post* = ref object
    fallback*: string
    pretext*: string
    title*: string
    text*: string
    color*: string
    footer*: string

  Payload* = ref object
    attachments*: seq[Post]
