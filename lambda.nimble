# Package

version       = "0.2.0"
author        = "limit7412"
description   = "my serverless nim runtime for sls"
license       = "MIT"
srcDir        = "src"
bin           = @["main"]

backend       = "cpp"

# Dependencies

requires "nim >= 1.2.0"
