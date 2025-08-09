# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "avarex_llama")
project(${PROJECT_NAME} LANGUAGES CXX)

# Invoke the build for native code shared with the other target platforms.
# This can be changed to accommodate different builds.
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../src" "${CMAKE_CURRENT_BINARY_DIR}/shared")

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
# Defined in ../src/CMakeLists.txt.
# This can be changed to accommodate different builds.
find_package(CUDAToolkit QUIET)
if(CUDAToolkit_FOUND)
  set(avarex_llama_bundled_libraries
    $<TARGET_FILE:avarex_llama>
    $<TARGET_FILE:ggml>
    $<TARGET_FILE:ggml-base>
    $<TARGET_FILE:ggml-cpu>
    $<TARGET_FILE:llama>
    PARENT_SCOPE
  )
else()
  set(avarex_llama_bundled_libraries
    $<TARGET_FILE:avarex_llama>
    $<TARGET_FILE:ggml>
    $<TARGET_FILE:ggml-base>
    $<TARGET_FILE:ggml-cpu>
    $<TARGET_FILE:ggml-cuda>
    $<TARGET_FILE:llama>
    PARENT_SCOPE
  )
endif()