#!/bin/sh

mkdir actions-runner && cd actions-runner

curl -o actions-runner-linux-x64-2.331.0.tar.gz \
  -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-linux-x64-2.331.0.tar.gz

echo "5fcc01bd546ba5c3f1291c2803658ebd3cedb3836489eda3be357d41bfcf28a7  actions-runner-linux-x64-2.331.0.tar.gz" \
  | shasum -a 256 -c

tar xzf ./actions-runner-linux-x64-2.331.0.tar.gz