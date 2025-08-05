# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "llama")
project(${PROJECT_NAME} VERSION 0.0.1 LANGUAGES CXX)

set(API_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(LLAMA_CPP_DIR ${API_DIR}/llama_cpp)

find_package(CUDA REQUIRED)
if(CUDA_FOUND)
    message(STATUS "CUDA compiler found, so setting build var to have llama.cpp/ggml use CUDA")
    set(GGML_CUDA ON)
else()
    message(STATUS "CUDA compiler not found. Building without CUDA support.")
endif()

set(BUILD_SHARED_LIBS ON)
set(CMAKE_INSTALL_LIBDIR lib CACHE PATH "library install dir" FORCE)

add_subdirectory(${LLAMA_CPP_DIR} ${CMAKE_CURRENT_BINARY_DIR}/shared)

target_include_directories(
  llama 
  PRIVATE 
  ${LLAMA_CPP_DIR}/common
)
target_sources(
  llama 
  PUBLIC 
  ${API_DIR}/avarex_llama.cpp
)
set_target_properties(llama PROPERTIES
  PUBLIC_HEADER ${API_DIR}/avarex_llama.hpp
  BUILD_WITH_INSTALL_RPATH TRUE
  INSTALL_RPATH "$ORIGIN"
)

target_compile_definitions(llama PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(llama PRIVATE "-Wl,-z,max-page-size=16384")
endif()

# Add test app
add_executable(llama_test avarex_llama.cpp)
target_link_libraries(llama_test PRIVATE llama)