# !/usr/bin/env bash

set -exuo pipefail

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == 1 ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc"
fi

export CXXFLAGS="${CXXFLAGS} -Wno-deprecated-declarations"
export CFLAGS="${CFLAGS} -Wno-deprecated-declarations"
mkdir -p build

# Build npu_compiler (libopenvino_intel_npu_compiler.so) as an extra module of
# this single shared OpenVINO build; its LLVM/MLIR fork links static in-tree.
NPU_COMPILER_ARGS=()
if [[ "${target_platform}" == "linux-64" ]]; then
    NPU_COMPILER_ARGS=(
        -DOPENVINO_EXTRA_MODULES="$SRC_DIR/src/plugins/intel_npu/npu_compiler"
        -DBUILD_COMPILER_FOR_DRIVER=OFF
        -DENABLE_PREBUILT_LLVM_MLIR_LIBS=OFF
        -DLLVM_USE_LINKER=lld
        -DLLVM_PARALLEL_LINK_JOBS=2  # cap: parallel LLVM links OOM the runner
        -DCMAKE_C_COMPILER_LAUNCHER=ccache
        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
    )
fi

# ENABLE_INTEL_NPU_COMPILER below toggles *downloading* Intel's prebuilt NPU
# compiler (download_compiler_libs.cmake), not building one -- keep it OFF; we
# build the compiler from source via OPENVINO_EXTRA_MODULES.
cmake ${CMAKE_ARGS}                                                          \
    -DENABLE_SYSTEM_TBB=ON                                                   \
    -DENABLE_PROFILING_ITT=OFF                                               \
    -DENABLE_SYSTEM_PUGIXML=ON                                               \
    -DENABLE_SYSTEM_PROTOBUF=ON                                              \
    -DENABLE_SYSTEM_SNAPPY=ON                                                \
    -DENABLE_SYSTEM_LEVEL_ZERO=ON                                            \
    -DENABLE_INTEL_NPU_INTERNAL=OFF                                          \
    -DENABLE_INTEL_NPU_COMPILER=OFF                                          \
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
    ${NPU_COMPILER_ARGS[@]+"${NPU_COMPILER_ARGS[@]}"}                        \
    -G Ninja                                                                 \
    -S "$SRC_DIR"                                                            \
    -B "$SRC_DIR/build"

cmake --build "$SRC_DIR/build" --config Release --parallel $CPU_COUNT
