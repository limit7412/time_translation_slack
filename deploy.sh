#!/bin/bash

stg=$1
[ "$stg" = "" ] && stg="dev"

[ -e bootstrap ] && sudo rm bootstrap

# nimlang/nim nimble build -d:ssl --passL:-static -d:release --opt:size  && \
sudo docker run --rm -v $(pwd):/src -w /src         \
nimlang/nim:1.0.6 nimble build -d:ssl            && \
mv main bootstrap                                && \
sudo chmod +x bootstrap                          || exit 1

sls deploy -s $stg
