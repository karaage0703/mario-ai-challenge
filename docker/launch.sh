#!/usr/bin/env bash
set -eu

SRC_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

docker run --gpus all -it --rm -p 8888:8888 -v $SRC_DIR/workspace:/workspace mario-ai-challenge:latest
