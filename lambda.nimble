# Package

version       = "0.1.0"
author        = "limit7412"
description   = "my serverless nim runtime for sls"
license       = "MIT"
srcDir        = "src"
bin           = @["main"]

backend       = "cpp"

# Dependencies

# FIXME: change use latest
requires "nim >= 1.0.6"
