#!/usr/bin/env bash
set -ex

cmake --install "$SRC_DIR/build" --component npu

# npu_compiler is an extra-module target, so OpenVINO emits it to its
# OUTPUT_ROOT bin dir (the source tree) rather than under build/.
install -m 0755                                                              \
    "$SRC_DIR/bin/intel64/Release/libopenvino_intel_npu_compiler.so"         \
    "$PREFIX/lib/openvino-${PKG_VERSION}/libopenvino_intel_npu_compiler.so"
