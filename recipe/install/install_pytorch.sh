# !/usr/bin/env bash

cmake --build "$SRC_DIR/../build" --config Release --verbose --parallel $CPU_COUNT --target openvino_pytorch_frontend
cmake --install "$SRC_DIR/../build" --component pytorch
