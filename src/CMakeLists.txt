# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "avarex_llama")
project(${PROJECT_NAME} VERSION 0.0.1 LANGUAGES CXX)

set(API_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(LLAMA_CPP_DIR ${API_DIR}/llama_cpp)

find_package(CUDAToolkit QUIET)
if(CUDAToolkit_FOUND)
    message(STATUS "CUDA compiler found, so setting build var to have llama.cpp/ggml use CUDA")
    set(GGML_CUDA ON)
else()
    message(STATUS "CUDA compiler not found. Building without CUDA support.")
endif()

set(CMAKE_INSTALL_LIBDIR lib CACHE PATH "library install dir" FORCE) # ???
set(BUILD_SHARED_LIBS ON)

add_subdirectory(${LLAMA_CPP_DIR} ${CMAKE_CURRENT_BINARY_DIR}/shared)

add_library(${PROJECT_NAME} SHARED)
target_link_libraries(${PROJECT_NAME} PUBLIC llama)
target_include_directories(
  ${PROJECT_NAME} 
  PRIVATE ${LLAMA_CPP_DIR}/common
)
target_sources(
  ${PROJECT_NAME} 
  PUBLIC 
  ${API_DIR}/avarex_llama.cpp
)
set_target_properties(${PROJECT_NAME} PROPERTIES
  PUBLIC_HEADER ${API_DIR}/avarex_llama.h
  BUILD_WITH_INSTALL_RPATH TRUE
  INSTALL_RPATH "$ORIGIN"
)

target_compile_definitions(${PROJECT_NAME} PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(${PROJECT_NAME} PRIVATE "-Wl,-z,max-page-size=16384")
endif()

# Add test app
if (DEFINED BUILD_TEST_EXE)
  add_executable(llama_test avarex_llama.cpp)
  target_link_libraries(llama_test PRIVATE llama ${PROJECT_NAME})
endif()