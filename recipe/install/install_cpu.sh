# !/usr/bin/env bash

cmake --build "$SRC_DIR/../build" --config Release --verbose --parallel $CPU_COUNT --target openvino_intel_cpu_plugin
cmake --install "$SRC_DIR/../build" --component cpu
