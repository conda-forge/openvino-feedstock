#include <stdlib.h>

#include <openvino/c/openvino.h>
#include <openvino/core/visibility.hpp>

#define OV_CALL(statement) \
    if ((statement) != 0) \
        return EXIT_FAILURE;

int main() {
    ov_core_t* core = NULL;
    char* ret = NULL;
    printf("ov_core_create\n");
    OV_CALL(ov_core_create(&core));
    printf("ov_core_get_property CPU\n");
    OV_CALL(ov_core_get_property(core, "CPU", "AVAILABLE_DEVICES", &ret));
#if defined(OPENVINO_ARCH_X86_64) && !defined(__APPLE__)
    printf("ov_core_get_property GPU\n");
    OV_CALL(ov_core_get_property(core, "GPU", "AVAILABLE_DEVICES", &ret));
#endif
    printf("ov_core_get_property AUTO\n");
    OV_CALL(ov_core_get_property(core, "AUTO", "SUPPORTED_METRICS", &ret));
    printf("ov_core_get_property MULTI\n");
    OV_CALL(ov_core_get_property(core, "MULTI", "SUPPORTED_METRICS", &ret));
    printf("ov_core_get_property HETERO\n");
    OV_CALL(ov_core_get_property(core, "HETERO", "SUPPORTED_METRICS", &ret));
    printf("ov_core_get_property BATCH\n");
    OV_CALL(ov_core_get_property(core, "BATCH", "SUPPORTED_METRICS", &ret));
    printf("ov_core_free\n");
    ov_core_free(core);
    return EXIT_SUCCESS;
}
