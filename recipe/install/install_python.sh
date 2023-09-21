# !/usr/bin/env bash

export CMAKE_BUILD_TYPE="Debug"
export OPENVINO_BINARY_DIR="$SRC_DIR/build"
export PY_PACKAGES_DIR="lib/python$PY_VER/site-packages"
export WHEEL_VERSION="$PKG_VERSION"
export PYTHON_EXTENSIONS_ONLY="1"
export SKIP_RPATH="1"
export CPACK_GENERATOR="CONDA-FORGE"

$PYTHON -m pip install --no-deps --ignore-installed -v "$SRC_DIR/src/bindings/python/wheel"
