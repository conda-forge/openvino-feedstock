echo ON
setlocal enabledelayedexpansion

mkdir -p build

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
    -S "%SRC_DIR%"                                                           ^
    -B "%SRC_DIR%/build"
if errorlevel 1 exit 1

cmake --build "%SRC_DIR%/build" --config Release --parallel %CPU_COUNT% --verbose
if errorlevel 1 exit 1

exit 0
