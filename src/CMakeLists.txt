# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(avarex_llama_library VERSION 0.0.1 LANGUAGES C)

add_library(avarex_llama SHARED
  "avarex_llama.c"
)

set_target_properties(avarex_llama PROPERTIES
  PUBLIC_HEADER avarex_llama.h
  OUTPUT_NAME "avarex_llama"
)

target_compile_definitions(avarex_llama PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(avarex_llama PRIVATE "-Wl,-z,max-page-size=16384")
endif()
