# !/usr/bin/env bash

set -exuo pipefail

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == 1 ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc"
fi

export CXXFLAGS="${CXXFLAGS} -Wno-deprecated-declarations"
export CFLAGS="${CFLAGS} -Wno-deprecated-declarations"
mkdir -p build

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
    -G Ninja                                                                 \
    -S "$SRC_DIR"                                                            \
    -B "$SRC_DIR/build"

cmake --build "$SRC_DIR/build" --config Release --parallel $CPU_COUNT

# ----------------------------------------------------------------------------
# NPU driver compiler (libopenvino_intel_npu_compiler.so) — built from source.
#
# The main OpenVINO build above is configured shared and with
# ENABLE_INTEL_NPU_COMPILER=OFF, so it neither downloads Intel's prebuilt
# vcl nor builds the compiler itself.  Here we do a second, *static*
# OpenVINO configure that pulls openvinotoolkit/npu_compiler in as an
# OPENVINO_EXTRA_MODULES module and builds only the
# openvino_intel_npu_compiler target.  npu_compiler statically links its
# vendored LLVM/MLIR 20.x fork (Intel's npu-compiler-llvm) into the .so,
# so the result is a self-contained module loaded via dlopen by the NPU
# plugin.  install/install_npu.sh copies the produced .so next to
# libopenvino_intel_npu_plugin.so.
# ----------------------------------------------------------------------------
if [[ "${target_platform}" == "linux-64" ]]; then
    NPU_COMPILER_SRC="$SRC_DIR/src/plugins/intel_npu/npu_compiler"
    NPU_COMPILER_BUILD="$SRC_DIR/build_npucompiler"

    # Cap link parallelism: linking LLVM/MLIR is the memory spike and
    # over-parallel links OOM the runner.  Compiles can use all cores.
    NPU_LINK_JOBS=2

    cmake ${CMAKE_ARGS}                                                      \
        -DCMAKE_BUILD_TYPE=Release                                           \
        -DBUILD_SHARED_LIBS=OFF                                              \
        -DOPENVINO_EXTRA_MODULES="${NPU_COMPILER_SRC}"                       \
        -DBUILD_COMPILER_FOR_DRIVER=OFF                                      \
        -DENABLE_LTO=OFF                                                     \
        -DENABLE_TESTS=OFF                                                   \
        -DENABLE_FUNCTIONAL_TESTS=OFF                                        \
        -DENABLE_SAMPLES=OFF                                                 \
        -DENABLE_JS=OFF                                                      \
        -DENABLE_PYTHON=OFF                                                  \
        -DENABLE_PYTHON_PACKAGING=OFF                                        \
        -DENABLE_WHEEL=OFF                                                   \
        -DENABLE_CPPLINT=OFF                                                 \
        -DENABLE_CLANG_FORMAT=OFF                                            \
        -DENABLE_NCC_STYLE=OFF                                               \
        -DENABLE_OV_IR_FRONTEND=ON                                           \
        -DENABLE_OV_ONNX_FRONTEND=OFF                                        \
        -DENABLE_OV_PYTORCH_FRONTEND=OFF                                     \
        -DENABLE_OV_PADDLE_FRONTEND=OFF                                      \
        -DENABLE_OV_TF_FRONTEND=OFF                                          \
        -DENABLE_OV_JAX_FRONTEND=OFF                                         \
        -DTHREADING=TBB                                                      \
        -DENABLE_SYSTEM_TBB=ON                                               \
        -DENABLE_TBBBIND_2_5=OFF                                             \
        -DENABLE_SYSTEM_PUGIXML=ON                                           \
        -DENABLE_SYSTEM_PROTOBUF=ON                                          \
        -DENABLE_SYSTEM_SNAPPY=ON                                            \
        -DENABLE_SYSTEM_LEVEL_ZERO=ON                                        \
        -DENABLE_SYSTEM_FLATBUFFERS=OFF                                      \
        -DENABLE_HETERO=OFF                                                  \
        -DENABLE_MULTI=OFF                                                   \
        -DENABLE_AUTO=OFF                                                    \
        -DENABLE_AUTO_BATCH=OFF                                              \
        -DENABLE_TEMPLATE=OFF                                                \
        -DENABLE_PROXY=OFF                                                   \
        -DENABLE_INTEL_CPU=OFF                                               \
        -DENABLE_INTEL_GPU=OFF                                               \
        -DENABLE_INTEL_NPU=ON                                                \
        -DENABLE_INTEL_NPU_COMPILER=OFF                                      \
        -DENABLE_NPU_PLUGIN_ENGINE=OFF                                       \
        -DENABLE_ZEROAPI_BACKEND=OFF                                         \
        -DENABLE_DRIVER_COMPILER_ADAPTER=OFF                                 \
        -DENABLE_INTEL_NPU_INTERNAL=OFF                                      \
        -DENABLE_INTEL_NPU_PROTOPIPE=OFF                                     \
        -DENABLE_NPU_LSP_SERVER=OFF                                          \
        -DENABLE_PROFILING_ITT=OFF                                           \
        -DENABLE_PREBUILT_LLVM_MLIR_LIBS=OFF                                 \
        -DLLVM_USE_LINKER=lld                                                \
        -DLLVM_PARALLEL_LINK_JOBS=${NPU_LINK_JOBS}                           \
        -DCMAKE_C_COMPILER_LAUNCHER=ccache                                   \
        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache                                 \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5                                   \
        -G Ninja                                                             \
        -S "$SRC_DIR"                                                        \
        -B "${NPU_COMPILER_BUILD}"

    cmake --build "${NPU_COMPILER_BUILD}"                                    \
        --config Release                                                     \
        --target openvino_intel_npu_compiler                                 \
        --parallel $CPU_COUNT

    # Locate the produced library for install_npu.sh to pick up.
    # (Existence under $PREFIX after install is verified by the
    # libopenvino-intel-npu-plugin test: commands in meta.yaml.)
    NPU_COMPILER_SO=$(find "${NPU_COMPILER_BUILD}" -name 'libopenvino_intel_npu_compiler.so' -type f | head -n 1)
    echo "Built NPU compiler: ${NPU_COMPILER_SO}"
fi
