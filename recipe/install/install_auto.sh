# !/usr/bin/env bash

echo "cmake --build "$SRC_DIR/../build" --config Release --verbose --parallel $CPU_COUNT --target openvino_auto_plugin"
cmake --build "$SRC_DIR/../build" --config Release --verbose --parallel $CPU_COUNT --target openvino_auto_plugin
echo "cmake --install "$SRC_DIR/../build" --component multi"
