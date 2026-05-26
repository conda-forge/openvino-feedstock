#!/usr/bin/env bash
set -ex

# Install libopenvino_npu_compiler_support.so + its headers + cmake config.
# Built as an OPENVINO_EXTRA_MODULES of the main build (see build.sh and
# recipe/npu_compiler_support/CMakeLists.txt), so the component install rules
# are part of the single OpenVINO build tree.
cmake --install "$SRC_DIR/build" --component npu_compiler_support
