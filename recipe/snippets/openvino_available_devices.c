#include <stdlib.h>

#include <openvino/c/openvino.h>
#include <openvino/core/visibility.hpp>

#define OV_CALL(statement)   \
    if ((statement) != 0)    \
        return EXIT_FAILURE;

int main() {
    ov_core_t* core = NULL;
    char* ret = NULL;
    OV_CALL(ov_core_create(&core));
    OV_CALL(ov_core_get_property(core, "CPU", "AVAILABLE_DEVICES", &ret));
#if defined(OPENVINO_ARCH_X86_64) && !defined(__APPLE__)
    OV_CALL(ov_core_get_property(core, "GPU", "AVAILABLE_DEVICES", &ret));
    // OV_CALL(ov_core_get_property(core, "NPU", "AVAILABLE_DEVICES", &ret));
#endif
    OV_CALL(ov_core_get_property(core, "AUTO", "SUPPORTED_PROPERTIES", &ret));
    OV_CALL(ov_core_get_property(core, "MULTI", "SUPPORTED_PROPERTIES", &ret));
    OV_CALL(ov_core_get_property(core, "HETERO", "SUPPORTED_PROPERTIES", &ret));
    OV_CALL(ov_core_get_property(core, "BATCH", "SUPPORTED_PROPERTIES", &ret));
    ov_core_free(core);
    return EXIT_SUCCESS;
}
