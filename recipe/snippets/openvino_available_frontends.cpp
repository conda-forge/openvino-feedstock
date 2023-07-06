#include <openvino/frontend/manager.hpp>

int main() {
    return ov::frontend::FrontEndManager().get_available_front_ends().size() == 5 ? 0 : 1;
}
