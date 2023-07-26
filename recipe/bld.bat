echo ON
setlocal enabledelayedexpansion

mkdir -p build


if %cuda_compiler_version% == "None" (
    cmake                                                                               ^
        -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                                       ^
        -DCMAKE_BUILD_TYPE=Release                                                      ^
        -DENABLE_INTEL_GNA=OFF                                                          ^
        -DENABLE_SYSTEM_TBB=ON                                                          ^
        -DENABLE_SYSTEM_PUGIXML=ON                                                      ^
        -DENABLE_SYSTEM_OPENCL=ON                                                       ^
        -DENABLE_SYSTEM_PROTOBUF=ON                                                     ^
        -DENABLE_SYSTEM_SNAPPY=ON                                                       ^
        -DBUILD_nvidia_plugin=OFF                                                       ^
        -DENABLE_COMPILE_TOOL=OFF                                                       ^
        -DENABLE_PYTHON=OFF                                                             ^
        -DENABLE_CPPLINT=OFF                                                            ^
        -DENABLE_CLANG_FORMAT=OFF                                                       ^
        -DENABLE_NCC_STYLE=OFF                                                          ^
        -DENABLE_TEMPLATE=OFF                                                           ^
        -DENABLE_SAMPLES=OFF                                                            ^
        -DENABLE_DATA=OFF                                                               ^
        -DCPACK_GENERATOR=CONDA-FORGE                                                   ^
        -G "Visual Studio 16 2019"                                                                         ^
        -S "%SRC_DIR%"                                                                  ^
        -B "%SRC_DIR%/build"
) ELSE (
    cmake                                                                               ^
        -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                                       ^
        -DCMAKE_BUILD_TYPE=Release                                                      ^
        -DENABLE_INTEL_GNA=OFF                                                          ^
        -DENABLE_INTEL_CPU=OFF                                                          ^
        -DENABLE_OV_ONNX_FRONTEND=OFF                                                   ^
        -DENABLE_OV_PADDLE_FRONTEND=OFF                                                 ^
        -DENABLE_OV_IR_FRONTEND=OFF                                                     ^
        -DENABLE_OV_PYTORCH_FRONTEND=OFF                                                ^
        -DENABLE_OV_IR_FRONTEND=OFF                                                     ^
        -DENABLE_OV_TF_FRONTEND=OFF                                                     ^
        -DENABLE_OV_TF_LITE_FRONTEND=OFF                                                ^
        -DENABLE_MULTI=OFF                                                              ^
        -DENABLE_AUTO=OFF                                                               ^
        -DENABLE_AUTO_BATCH=OFF                                                         ^
        -DENABLE_HETERO=OFF                                                             ^
        -DENABLE_SYSTEM_TBB=ON                                                          ^
        -DENABLE_SYSTEM_PUGIXML=ON                                                      ^
        -DENABLE_SYSTEM_OPENCL=ON                                                       ^
        -DENABLE_SYSTEM_PROTOBUF=ON                                                     ^
        -DENABLE_SYSTEM_SNAPPY=ON                                                       ^
        -DOPENVINO_EXTRA_MODULES="%SRC_DIR%/openvino_contrib/modules/nvidia_plugin"     ^
        -DBUILD_nvidia_plugin=ON                                                        ^
        -DENABLE_COMPILE_TOOL=OFF                                                       ^
        -DENABLE_PYTHON=OFF                                                             ^
        -DENABLE_CPPLINT=OFF                                                            ^
        -DENABLE_CLANG_FORMAT=OFF                                                       ^
        -DENABLE_NCC_STYLE=OFF                                                          ^
        -DENABLE_TEMPLATE=OFF                                                           ^
        -DENABLE_SAMPLES=OFF                                                            ^
        -DENABLE_DATA=OFF                                                               ^
        -DCPACK_GENERATOR=CONDA-FORGE                                                   ^
        -G "Visual Studio 16 2019"                                                                         ^
        -S "%SRC_DIR%"                                                                  ^
        -B "%SRC_DIR%/build"
)
        
if errorlevel 1 exit 1

cmake --build "%SRC_DIR%/build" --config Release --verbose
if errorlevel 1 exit 1

cp "%SRC_DIR%/LICENSE" LICENSE
cp "%SRC_DIR%/licensing/third-party-programs.txt" third-party-programs.txt
cp "%SRC_DIR%/licensing/onednn_third-party-programs.txt" onednn_third-party-programs.txt
cp "%SRC_DIR%/licensing/runtime-third-party-programs.txt" runtime-third-party-programs.txt
cp "%SRC_DIR%/licensing/tbb_third-party-programs.txt" tbb_third-party-programs.txt

exit 0
