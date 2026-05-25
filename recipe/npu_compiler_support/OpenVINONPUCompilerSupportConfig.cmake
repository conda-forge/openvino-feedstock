# Minimal config for libopenvino_npu_compiler_support.so, shipped by the
# conda-forge openvino feedstock (output: libopenvino-npu-compiler-support).
# Consumed by the Intel NPU driver compiler build (intel-driver-compiler-npu)
# to link the npu_al / npu_ops / xml_util symbols against a SHARED lib instead
# of OpenVINO-internal static libs. Relocatable: resolves paths from $PREFIX.
get_filename_component(_ovnpucs_root "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)

add_library(openvino::npu_compiler_support SHARED IMPORTED)
set_target_properties(openvino::npu_compiler_support PROPERTIES
    IMPORTED_LOCATION "${_ovnpucs_root}/lib/libopenvino_npu_compiler_support.so"
    INTERFACE_INCLUDE_DIRECTORIES "${_ovnpucs_root}/include/npu_compiler_support")
