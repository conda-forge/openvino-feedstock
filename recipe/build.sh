# !/usr/bin/env bash

set +ex

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc"
fi

export PKG_CONFIG_LIBDIR=$PREFIX/lib:$BUILD_PREFIX/lib
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig:$BUILD_PREFIX/lib/pkgconfig

mkdir -p openvino-build

cmake "${CMAKE_ARGS}"                                                        \
    -DCMAKE_BUILD_TYPE=Release                                               \
    -DENABLE_INTEL_GNA=OFF                                                   \
    -DENABLE_SYSTEM_TBB=ON                                                   \
    -DENABLE_SYSTEM_PUGIXML=ON                                               \
    -DENABLE_SYSTEM_PROTOBUF=ON                                              \
    -DENABLE_SYSTEM_SNAPPY=ON                                                \
    -DENABLE_COMPILE_TOOL=OFF                                                \
    -DENABLE_PYTHON=OFF                                                      \
    -DENABLE_CPPLINT=OFF                                                     \
    -DENABLE_CLANG_FORMAT=OFF                                                \
    -DENABLE_NCC_STYLE=OFF                                                   \
    -DENABLE_TEMPLATE=OFF                                                    \
    -DENABLE_SAMPLES=OFF                                                     \
    -DENABLE_DATA=OFF                                                        \
    -DCPACK_GENERATOR=CONDA-FORGE                                            \
    -G Ninja                                                                 \
    -S "$SRC_DIR/openvino_sources"                                           \
    -B "$SRC_DIR/openvino-build"

cmake --build "$SRC_DIR/openvino-build" --config Release --parallel $CPU_COUNT --verbose

cp "$SRC_DIR/openvino_sources/LICENSE" LICENSE
cp "$SRC_DIR/openvino_sources/licensing/third-party-programs.txt" third-party-programs.txt
cp "$SRC_DIR/openvino_sources/licensing/onednn_third-party-programs.txt" onednn_third-party-programs.txt
cp "$SRC_DIR/openvino_sources/licensing/runtime-third-party-programs.txt" runtime-third-party-programs.txt
cp "$SRC_DIR/openvino_sources/licensing/tbb_third-party-programs.txt" tbb_third-party-programs.txt
