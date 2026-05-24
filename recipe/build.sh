# !/usr/bin/env bash

set -exuo pipefail

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == 1 ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc"
fi

export CXXFLAGS="${CXXFLAGS} -Wno-deprecated-declarations"
export CFLAGS="${CFLAGS} -Wno-deprecated-declarations"
mkdir -p build

# ----------------------------------------------------------------------------
# NPU driver compiler (libopenvino_intel_npu_compiler.so) — built from source,
# in-tree with this single *shared* OpenVINO build (linux-64 only).
#
# Instead of a second, *static* OpenVINO configure, openvinotoolkit/npu_compiler
# is pulled in as an OPENVINO_EXTRA_MODULES module of the main build.  OpenVINO
# core therefore links *shared* (the compiler .so gets a normal libopenvino.so
# DT_NEEDED, exactly like the NPU plugin), while npu_compiler's vendored
# LLVM/MLIR 20.x fork is still built in-tree and *statically* linked into the
# compiler .so (ENABLE_PREBUILT_LLVM_MLIR_LIBS=OFF).  This avoids recompiling a
# whole static OpenVINO and shrinks the resulting library.
# ----------------------------------------------------------------------------
NPU_COMPILER_ARGS=()
if [[ "${target_platform}" == "linux-64" ]]; then
    # Cap LLVM/MLIR link parallelism: linking is the memory spike and
    # over-parallel links OOM the runner.  Compiles still use all cores.
    NPU_COMPILER_ARGS=(
        -DOPENVINO_EXTRA_MODULES="$SRC_DIR/src/plugins/intel_npu/npu_compiler"
        -DBUILD_COMPILER_FOR_DRIVER=OFF
        -DENABLE_PREBUILT_LLVM_MLIR_LIBS=OFF
        -DLLVM_USE_LINKER=lld
        -DLLVM_PARALLEL_LINK_JOBS=2
        -DCMAKE_C_COMPILER_LAUNCHER=ccache
        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
    )
fi

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

if [[ "${target_platform}" == "linux-64" ]]; then
    # Ensure the NPU compiler target is built (it may be EXCLUDE_FROM_ALL),
    # then locate the produced library for install_npu.sh to pick up.
    # (Existence under $PREFIX after install is verified by the
    # libopenvino-intel-npu-plugin test: commands in meta.yaml.)
    cmake --build "$SRC_DIR/build" --config Release                          \
        --target openvino_intel_npu_compiler --parallel $CPU_COUNT

    NPU_COMPILER_SO=$(find "$SRC_DIR/build" -name 'libopenvino_intel_npu_compiler.so' -type f | head -n 1)
    echo "Built NPU compiler: ${NPU_COMPILER_SO}"
fi
