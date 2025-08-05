#if _WIN32
#include <windows.h>
#endif

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

FFI_PLUGIN_EXPORT char* run_generation(char* promptc, int n_predict);
FFI_PLUGIN_EXPORT void start_llama(char* model_path);
FFI_PLUGIN_EXPORT void free_string(char* str);