echo ON
setlocal enabledelayedexpansion

mkdir -p build

set CFLAGS=%CFLAGS% /wd4996
set CXXFLAGS=%CXXFLAGS% /wd4996

cmake %CMAKE_ARGS%                                                           ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                                ^
    -DCMAKE_BUILD_TYPE=Release                                               ^
    -DENABLE_SYSTEM_TBB=ON                                                   ^
    -DENABLE_SYSTEM_PUGIXML=ON                                               ^
    -DENABLE_OV_JAX_FRONTEND=OFF                                             ^
    -DENABLE_INTEL_NPU_INTERNAL=OFF                                          ^
    -DENABLE_SYSTEM_OPENCL=ON                                                ^
    -DENABLE_SYSTEM_PROTOBUF=ON                                              ^
    -DENABLE_SYSTEM_SNAPPY=ON                                                ^
    -DENABLE_JS=OFF                                                          ^
    -DENABLE_PYTHON=OFF                                                      ^
    -DENABLE_CPPLINT=OFF                                                     ^
    -DENABLE_CLANG_FORMAT=OFF                                                ^
    -DENABLE_NCC_STYLE=OFF                                                   ^
    -DENABLE_INTEL_NPU=OFF                                                   ^
    -DENABLE_TEMPLATE=OFF                                                    ^
    -DENABLE_SAMPLES=OFF                                                     ^
    -DCPACK_GENERATOR=CONDA-FORGE                                            ^
    -G Ninja                                                                 ^
    -S "%SRC_DIR%"                                                           ^
    -B "%SRC_DIR%\build"
if errorlevel 1 exit 1

:REM on the CI running compilation in parallel results in out of memory errors
cmake --build "%SRC_DIR%\build" --config Release --parallel 1
if errorlevel 1 exit 1
