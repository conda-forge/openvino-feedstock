# !/usr/bin/env bash

set -exuo pipefail

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == 1 ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc"
fi

mkdir -p build

cmake ${CMAKE_ARGS}                                                          \
    -DCMAKE_BUILD_TYPE=Release                                               \
    -DENABLE_SYSTEM_TBB=ON                                                   \
    -DENABLE_SYSTEM_PUGIXML=ON                                               \
    -DENABLE_INTEL_NPU_INTERNAL=OFF                                          \
    -DENABLE_SYSTEM_PROTOBUF=ON                                              \
    -DENABLE_SYSTEM_SNAPPY=ON                                                \
    -DENABLE_JS=OFF                                                          \
    -DENABLE_PYTHON=OFF                                                      \
    -DENABLE_CPPLINT=OFF                                                     \
    -DENABLE_CLANG_FORMAT=OFF                                                \
    -DENABLE_NCC_STYLE=OFF                                                   \
    -DENABLE_TEMPLATE=OFF                                                    \
    -DENABLE_SAMPLES=OFF                                                     \
    -DCMAKE_CXX_FLAGS="-Wno-deprecated-declarations"                         \
    -DCMAKE_C_FLAGS="-Wno-deprecated-declarations"                           \
    -DCPACK_GENERATOR=CONDA-FORGE                                            \
    -G Ninja                                                                 \
    -S "$SRC_DIR"                                                            \
    -B "$SRC_DIR/build"

cmake --build "$SRC_DIR/build" --config Release --parallel $CPU_COUNT

cp "$SRC_DIR/licensing/third-party-programs.txt" third-party-programs.txt
cp "$SRC_DIR/licensing/onednn_third-party-programs.txt" onednn_third-party-programs.txt
cp "$SRC_DIR/licensing/runtime-third-party-programs.txt" runtime-third-party-programs.txt
