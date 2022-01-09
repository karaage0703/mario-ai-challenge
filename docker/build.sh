#!/usr/bin/env bash
set -eu

SRC_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

pushd ${SRC_DIR}
docker build -t mario-ai-challenge:latest .
popd
