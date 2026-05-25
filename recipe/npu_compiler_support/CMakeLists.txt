cmake_minimum_required(VERSION 3.24)
# Aggregated SHARED support library for the Intel NPU driver compiler.
#
# The NPU driver compiler (openvinotoolkit/npu_compiler -- the Compiler-in-Driver
# libnpu_driver_compiler.so, packaged separately as intel-driver-compiler-npu)
# links three OpenVINO-internal targets: npu_al, npu_ops, xml_util. Those are
# static, hidden-visibility libs whose transitive deps (reference,
# shape_inference, itt, util, ...) are also internal statics. conda-forge does
# not ship static libs, so instead of a static developer package we expose
# EXACTLY what the compiler needs as ONE shared library:
#   * recompile the npu_al/npu_ops/xml_util/logger SOURCES with default
#     visibility directly into this .so so their symbols are exportable;
#   * whole-archive the internal static deps (reference/shape_inference) so the
#     code is present, then --exclude-libs,ALL localizes those archive symbols
#     (keeps reference's ~19k template symbols hidden -> no ABI blowup, and no
#     ODR clash with the copies already private inside libopenvino.so);
#   * link the public SHARED openvino::runtime normally.
#
# Built as an OPENVINO_EXTRA_MODULES of the main OpenVINO build (see build.sh),
# so openvino::npu_al / reference / ... targets already exist here.
set(SUPPORT_TARGET openvino_npu_compiler_support)

set(_npu ${OpenVINO_SOURCE_DIR}/src/plugins/intel_npu)
file(GLOB_RECURSE AL_SRC  CONFIGURE_DEPENDS ${_npu}/src/al/src/*.cpp)
file(GLOB_RECURSE OPS_SRC CONFIGURE_DEPENDS ${_npu}/src/ops/src/*.cpp)
file(GLOB_RECURSE LOG_SRC CONFIGURE_DEPENDS ${_npu}/src/utils/src/logger/*.cpp)
file(GLOB_RECURSE XML_SRC CONFIGURE_DEPENDS ${OpenVINO_SOURCE_DIR}/src/core/xml_util/src/*.cpp)

add_library(${SUPPORT_TARGET} SHARED ${AL_SRC} ${OPS_SRC} ${LOG_SRC} ${XML_SRC})

set_target_properties(${SUPPORT_TARGET} PROPERTIES
    CXX_VISIBILITY_PRESET default
    C_VISIBILITY_PRESET default
    VISIBILITY_INLINES_HIDDEN OFF
    POSITION_INDEPENDENT_CODE ON)

target_include_directories(${SUPPORT_TARGET} PRIVATE
    $<TARGET_PROPERTY:openvino::npu_al,INTERFACE_INCLUDE_DIRECTORIES>
    $<TARGET_PROPERTY:openvino::npu_ops,INTERFACE_INCLUDE_DIRECTORIES>
    $<TARGET_PROPERTY:openvino::xml_util,INTERFACE_INCLUDE_DIRECTORIES>
    $<TARGET_PROPERTY:openvino::npu_logger_utils,INTERFACE_INCLUDE_DIRECTORIES>)

target_link_libraries(${SUPPORT_TARGET} PRIVATE
    openvino::runtime
    openvino::runtime::dev
    openvino::core::dev
    openvino::conditional_compilation
    $<LINK_LIBRARY:WHOLE_ARCHIVE,openvino::reference,openvino::shape_inference>)

# Localize the symbols pulled from the absorbed static archives (reference,
# shape_inference, itt, util, ...). The npu sources compiled directly above keep
# default visibility and remain exported.
target_link_options(${SUPPORT_TARGET} PRIVATE "LINKER:--exclude-libs,ALL")

#
# Install (component npu_compiler_support): the shared lib, the public headers
# the compiler needs, and a small cmake config exposing an imported target.
#
include(GNUInstallDirs)
set(_inc ${CMAKE_INSTALL_INCLUDEDIR}/npu_compiler_support)

install(TARGETS ${SUPPORT_TARGET}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        COMPONENT npu_compiler_support)

install(DIRECTORY
            ${_npu}/src/al/include/
            ${_npu}/src/ops/include/
            ${_npu}/src/utils/include/
            ${OpenVINO_SOURCE_DIR}/src/core/xml_util/include/
        DESTINATION ${_inc}
        COMPONENT npu_compiler_support
        FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp")

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/OpenVINONPUCompilerSupportConfig.cmake
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/OpenVINONPUCompilerSupport
        COMPONENT npu_compiler_support)
