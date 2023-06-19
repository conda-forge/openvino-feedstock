echo ON
setlocal enabledelayedexpansion

mkdir -p openvino_build

cmake                                                                        ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                                ^
    -DCMAKE_BUILD_TYPE=Release                                               ^
    -DENABLE_INTEL_GNA=OFF                                                   ^
    -DENABLE_SYSTEM_TBB=ON                                                   ^
    -DENABLE_SYSTEM_PUGIXML=ON                                               ^
    -DENABLE_SYSTEM_OPENCL=ON                                                ^
    -DENABLE_SYSTEM_PROTOBUF=ON                                              ^
    -DENABLE_SYSTEM_SNAPPY=ON                                                ^
    -DENABLE_COMPILE_TOOL=OFF                                                ^
    -DENABLE_PYTHON=OFF                                                      ^
    -DENABLE_CPPLINT=OFF                                                     ^
    -DENABLE_CLANG_FORMAT=OFF                                                ^
    -DENABLE_NCC_STYLE=OFF                                                   ^
    -DENABLE_TEMPLATE=OFF                                                    ^
    -DENABLE_SAMPLES=OFF                                                     ^
    -DENABLE_DATA=OFF                                                        ^
    -DCPACK_GENERATOR=CONDA-FORGE                                            ^
    -G Ninja                                                                 ^
    -S "%SRC_DIR%/openvino_sources"                                          ^
    -B "%SRC_DIR%/openvino_build"
if errorlevel 1 exit 1

cmake --build "%SRC_DIR%/openvino_build" --config Release --parallel %CPU_COUNT% --verbose
if errorlevel 1 exit 1

cp "%SRC_DIR%/openvino_sources/LICENSE" LICENSE
cp "%SRC_DIR%/openvino_sources/licensing/third-party-programs.txt" third-party-programs.txt
cp "%SRC_DIR%/openvino_sources/licensing/onednn_third-party-programs.txt" onednn_third-party-programs.txt
cp "%SRC_DIR%/openvino_sources/licensing/runtime-third-party-programs.txt" runtime-third-party-programs.txt
cp "%SRC_DIR%/openvino_sources/licensing/tbb_third-party-programs.txt" tbb_third-party-programs.txt

exit 0
