#if _WIN32
#include <windows.h>
#endif
#include "llama.h"

#if _WIN32
    #ifdef __cplusplus
        #define FFI_PLUGIN_EXPORT extern "C" __declspec(dllexport)
    #else
        #define FFI_PLUGIN_EXPORT __declspec(dllexport)
    #endif
#else
    #ifdef __cplusplus
        #define FFI_PLUGIN_EXPORT extern "C" 
    #else
        #define FFI_PLUGIN_EXPORT
    #endif
#endif

FFI_PLUGIN_EXPORT void start_llama(char* path_model, struct llama_model_params* i_model_params);
FFI_PLUGIN_EXPORT char* run_generation(char* promptc, int n_predict, struct llama_context_params* i_context_params, struct llama_sampler_chain_params* i_sampler_params);
FFI_PLUGIN_EXPORT void free_string(char* str);