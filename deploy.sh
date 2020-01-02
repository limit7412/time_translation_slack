#!/bin/bash

stg=$1
[ "$stg" = "" ] && stg="dev"

[ -e bootstrap ] && sudo rm bootstrap

sudo docker run --rm -v $(pwd):/src -w /src \
nimlang/nim nimble build -d:ssl && \
mv main bootstrap               && \
sudo chmod +x bootstrap         || exit 1

sls deploy -s $stg
