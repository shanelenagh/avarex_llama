#include "avarex_llama.h"
#include "llama.h"

// A very short-lived native function.
//
// For very short-lived functions, it is fine to call them on the main isolate.
// They will block the Dart execution while running the native function, so
// only do this for native functions which are guaranteed to be short-lived.
FFI_PLUGIN_EXPORT int sum(int a, int b) { return a + b; }

// A longer-lived native function, which occupies the thread calling it.
//
// Do not call these kind of native functions in the main isolate. They will
// block Dart execution. This will cause dropped frames in Flutter applications.
// Instead, call these native functions on a separate isolate.
FFI_PLUGIN_EXPORT int sum_long_running(int a, int b) {
  // Simulate work.
#if _WIN32
  Sleep(5000);
#else
  usleep(5000 * 1000);
#endif
  return a + b;
}


FFI_PLUGIN_EXPORT void start_llama(const char * path_model) {
   
    ggml_backend_load_all();

    struct llama_model_params model_params = llama_model_default_params();
    struct llama_context_params context_params = llama_context_default_params();    

    struct llama_model* model = llama_model_load_from_file(path_model, model_params);
    struct llama_context* ctx = llama_init_from_model(model, context_params);  

    struct llama_vocab* vocab = llama_model_get_vocab(model); 
    struct llama_sampler* sampler = llama_sampler_chain_init(llama_sampler_chain_default_params());
}
