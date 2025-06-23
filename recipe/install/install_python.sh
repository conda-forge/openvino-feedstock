#!/usr/bin/env bash
set -ex

if [[ "${target_platform}" == osx-64 ]]; then
    # https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
    # Address: error: 'path' is unavailable: introduced in macOS 10.15
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

export OPENVINO_BINARY_DIR="$SRC_DIR/build"
export PY_PACKAGES_DIR="lib/python$PY_VER/site-packages"
export WHEEL_VERSION="$PKG_VERSION"
export PYTHON_EXTENSIONS_ONLY="1"
export SKIP_RPATH="1"
export CPACK_GENERATOR="CONDA-FORGE"

$PYTHON -m pip install --no-deps --ignore-installed -v "$SRC_DIR"
