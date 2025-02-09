#!/usr/bin/env bash
set -ex

cmake --install "$SRC_DIR/build" --component gpu
