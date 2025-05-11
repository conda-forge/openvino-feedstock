#include <stdlib.h>

#include <openvino/c/openvino.h>
#include <openvino/core/visibility.hpp>

#define OV_CALL(statement)   \
    if ((statement) != 0)    \
        return EXIT_FAILURE;

int main() {
    ov_core_t* core = NULL;
    char* ret = NULL;
    printf("OpenVINO version: %s\n", ov_get_openvino_version());
    OV_CALL(ov_core_create(&core));
    printf("OpenVINO core created\n");
    OV_CALL(ov_core_get_property(core, "CPU", "AVAILABLE_DEVICES", &ret));
    printf("CPU available devices: %s\n", ret);
#if defined(OPENVINO_ARCH_X86_64) && !defined(__APPLE__)
    OV_CALL(ov_core_get_property(core, "GPU", "AVAILABLE_DEVICES", &ret));
    printf("GPU available devices: %s\n", ret);
    // OV_CALL(ov_core_get_property(core, "NPU", "AVAILABLE_DEVICES", &ret));
#endif
#ifdef CONDA_FORGE_OPENVINO_AUTO_FRONTEND
    OV_CALL(ov_core_get_property(core, "AUTO", "SUPPORTED_PROPERTIES", &ret));
    printf("AUTO supported properties: %s\n", ret);
#endif
#ifdef CONDA_FORGE_OPENVINO_MULTI_BACKEND
    OV_CALL(ov_core_get_property(core, "MULTI", "SUPPORTED_PROPERTIES", &ret));
    printf("MULTI supported properties: %s\n", ret);
#endif
#ifdef CONDA_FORGE_OPENVINO_HETERO_BACKEND
    OV_CALL(ov_core_get_property(core, "HETERO", "SUPPORTED_PROPERTIES", &ret));
    printf("HETERO supported properties: %s\n", ret);
#endif
#ifdef CONDA_FORGE_OPENVINO_BATCH_BACKEND
    OV_CALL(ov_core_get_property(core, "BATCH", "SUPPORTED_PROPERTIES", &ret));
    printf("BATCH supported properties: %s\n", ret);
#endif
    ov_core_free(core);
    return EXIT_SUCCESS;
}
