#!/usr/bin/env bash
set -ex

# Install the NPU plugin (libopenvino_intel_npu_plugin.so) from the
# main OpenVINO build.
cmake --install "$SRC_DIR/build" --component npu

# Install the from-source NPU driver compiler
# (libopenvino_intel_npu_compiler.so) built by build.sh as an OpenVINO
# extra module.  It is dlopen'd by the plugin and must sit next to it
# in the versioned openvino-<version> plugin directory.
NPU_COMPILER_SO=$(find "$SRC_DIR/build_npucompiler" -name 'libopenvino_intel_npu_compiler.so' -type f | head -n 1)
if [[ -z "${NPU_COMPILER_SO}" ]]; then
    echo "ERROR: libopenvino_intel_npu_compiler.so not found in build_npucompiler" >&2
    exit 1
fi

PLUGIN_DIR=$(dirname "$(find "$PREFIX/lib" -name 'libopenvino_intel_npu_plugin.so' -type f | head -n 1)")
if [[ -z "${PLUGIN_DIR}" ]]; then
    echo "ERROR: libopenvino_intel_npu_plugin.so not found under $PREFIX/lib" >&2
    exit 1
fi

install -m 0755 "${NPU_COMPILER_SO}" "${PLUGIN_DIR}/libopenvino_intel_npu_compiler.so"
