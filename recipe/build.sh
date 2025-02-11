# !/usr/bin/env bash

set -exuo pipefail

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == 1 ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc"
fi

if [[ "${target_platform}" == osx-64 ]]; then
    # https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
    # Address: error: 'path' is unavailable: introduced in macOS 10.15
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi
export CXXFLAGS="${CXXFLAGS} -Wno-deprecated-declarations"
export CFLAGS="${CFLAGS} -Wno-deprecated-declarations"
mkdir -p build

cmake ${CMAKE_ARGS}                                                          \
    -DENABLE_SYSTEM_TBB=ON                                                   \
    -DENABLE_SYSTEM_PUGIXML=ON                                               \
    -DENABLE_SYSTEM_PROTOBUF=ON                                              \
    -DENABLE_SYSTEM_SNAPPY=ON                                                \
    -DENABLE_SYSTEM_LEVEL_ZERO=ON                                            \
    -DENABLE_INTEL_NPU_INTERNAL=OFF                                          \
    -DENABLE_OV_JAX_FRONTEND=OFF                                             \
    -DENABLE_JS=OFF                                                          \
    -DENABLE_PYTHON=OFF                                                      \
    -DENABLE_CPPLINT=OFF                                                     \
    -DENABLE_CLANG_FORMAT=OFF                                                \
    -DENABLE_NCC_STYLE=OFF                                                   \
    -DENABLE_TEMPLATE=OFF                                                    \
    -DENABLE_SAMPLES=OFF                                                     \
    -DCPACK_GENERATOR=CONDA-FORGE                                            \
    -G Ninja                                                                 \
    -S "$SRC_DIR"                                                            \
    -B "$SRC_DIR/build"

cmake --build "$SRC_DIR/build" --config Release --parallel $CPU_COUNT
