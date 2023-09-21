# !/usr/bin/env bash

set +ex

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc"
fi

# use rapidjson from conda-forge dependencies
rm -fr "$SRC_DIR/src/plugins/intel_gpu/thirdparty/rapidjson"

mkdir -p build

cmake ${CMAKE_ARGS}                                                          \
    -DCMAKE_BUILD_TYPE=Debug                                                 \
    -DENABLE_INTEL_GNA=OFF                                                   \
    -DENABLE_SYSTEM_TBB=ON                                                   \
    -DENABLE_SYSTEM_PUGIXML=ON                                               \
    -DENABLE_SYSTEM_PROTOBUF=ON                                              \
    -DENABLE_SYSTEM_SNAPPY=ON                                                \
    -DENABLE_PYTHON=OFF                                                      \
    -DENABLE_CPPLINT=OFF                                                     \
    -DENABLE_CLANG_FORMAT=OFF                                                \
    -DENABLE_NCC_STYLE=OFF                                                   \
    -DENABLE_TEMPLATE=OFF                                                    \
    -DENABLE_SAMPLES=OFF                                                     \
    -DENABLE_DATA=OFF                                                        \
    -DCMAKE_CXX_FLAGS="-Wno-deprecated-declarations"                         \
    -DCMAKE_C_FLAGS="-Wno-deprecated-declarations"                           \
    -DCPACK_GENERATOR=CONDA-FORGE                                            \
    -G Ninja                                                                 \
    -S "$SRC_DIR"                                                            \
    -B "$SRC_DIR/build"

cmake --build "$SRC_DIR/build" --config Debug --parallel $CPU_COUNT --verbose

cp "$SRC_DIR/licensing/third-party-programs.txt" third-party-programs.txt
cp "$SRC_DIR/licensing/onednn_third-party-programs.txt" onednn_third-party-programs.txt
cp "$SRC_DIR/licensing/runtime-third-party-programs.txt" runtime-third-party-programs.txt
