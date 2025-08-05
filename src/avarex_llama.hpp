#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

#ifdef __cplusplus
extern "C" {
#endif

FFI_PLUGIN_EXPORT char* run_generation(char* promptc, int n_predict);
FFI_PLUGIN_EXPORT void start_llama(char* model_path);

#ifdef __cplusplus
}
#endif