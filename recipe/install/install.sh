# !/usr/bin/env bash

echo "cmake --build "$SRC_DIR/../build" --config Release --verbose --parallel $CPU_COUNT --target openvino"
cmake --build "$SRC_DIR/../build" --config Release --verbose --parallel $CPU_COUNT --target openvino
echo "cmake --build "$SRC_DIR/../build" --config Release --verbose --parallel $CPU_COUNT --target openvino_c"
cmake --build "$SRC_DIR/../build" --config Release --verbose --parallel $CPU_COUNT --target openvino_c
echo "cmake --build "$SRC_DIR/../build" --config Release --verbose --parallel $CPU_COUNT --target openvino_gapi_preproc"
cmake --build "$SRC_DIR/../build" --config Release --verbose --parallel $CPU_COUNT --target openvino_gapi_preproc
echo "cmake --install "$SRC_DIR/../build" --component core"
cmake --install "$SRC_DIR/../build" --component core
