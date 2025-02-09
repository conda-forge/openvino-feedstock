#!/usr/bin/env bash
set -ex

cmake --install "$SRC_DIR/build" --component core_dev
# remove requirements files since we shipped only c/cpp part
rm -rf $PREFIX/share/openvino
