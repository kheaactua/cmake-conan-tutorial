project(PclExample)

cmake_minimum_required(VERSION 3.0.2)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/Vendor)
find_package(OPAL_PCL)

add_executable(app main.cpp)
set_property(TARGET app PROPERTY CXX_STANDARD 11)

# Note, we could also include OPAL_PCL via a conan targer, i.e. CONAN_PKG::pcl,
# however this requires CMake >=1.1.2, which is higher than our current
# recommended CMake value.
target_link_libraries(app OPAL_PCL)
