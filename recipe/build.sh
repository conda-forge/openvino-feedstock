# !/usr/bin/env bash

set -exuo pipefail

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == 1 ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc"
fi

export CXXFLAGS="${CXXFLAGS} -Wno-deprecated-declarations"
export CFLAGS="${CFLAGS} -Wno-deprecated-declarations"
mkdir -p build

# Build libopenvino_npu_compiler_support.so as an extra module of this single
# OpenVINO build (linux-64 only). It re-exposes the NPU-internal npu_al/npu_ops/
# xml_util symbols the Intel NPU driver compiler needs as ONE shared library
# (no static libs), so intel-driver-compiler-npu can link them without
# rebuilding OpenVINO. See recipe/npu_compiler_support/CMakeLists.txt.
NPU_SUPPORT_ARGS=()
if [[ "${target_platform}" == "linux-64" ]]; then
    NPU_SUPPORT_ARGS=(
        -DOPENVINO_EXTRA_MODULES="$RECIPE_DIR/npu_compiler_support"
    )
fi

cmake ${CMAKE_ARGS}                                                          \
    ${NPU_SUPPORT_ARGS[@]+"${NPU_SUPPORT_ARGS[@]}"}                          \
    -DENABLE_SYSTEM_TBB=ON                                                   \
    -DENABLE_PROFILING_ITT=OFF                                               \
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
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5                                       \
    -DProtobuf_USE_STATIC_LIBS=OFF                                           \
    -DUSE_PROTOBUF_SHARED_LIBS=ON                                            \
    -DOV_FORCE_ADHOC_SIGN=ON                                                 \
    -G Ninja                                                                 \
    -S "$SRC_DIR"                                                            \
    -B "$SRC_DIR/build"

cmake --build "$SRC_DIR/build" --config Release --parallel $CPU_COUNT
