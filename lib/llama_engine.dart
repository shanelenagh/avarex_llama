import 'dart:ffi' as ffi;
// ignore: depend_on_referenced_packages (used as a string extension)
import 'package:ffi/ffi.dart';
import 'package:avarex_llama/avarex_llama_bindings_generated.dart' as avarex_llama;
import 'package:logging/logging.dart';

class LlamaEngine {

  final _log = Logger((LlamaEngine).toString());
  final avarex_llama.AvarexLlamaBindings _llamacppLib = avarex_llama.AvarexLlamaBindings(ffi.DynamicLibrary.open("llama.dll"));

  LlamaEngine(String modelPath, ModelConfig? modelConfig) {   
    _log.info("Starting llama.cpp with model $modelPath...");
    _llamacppLib.start_llama(_dart2ffi(modelPath), (modelConfig??ModelConfig())._getLlamaModelParams(_llamacppLib));
    _log.info("Started llama.cpp");
  }

  String runGeneration(String prompt, int nPredict, ContextConfig? contextConfig, SamplerConfig? samplerConfig) {
    return _ffi2dart(_llamacppLib.run_generation(_dart2ffi(prompt), nPredict, 
      (contextConfig??ContextConfig())._getLlamaContextParams(_llamacppLib), (samplerConfig??SamplerConfig())._getLlamaSamplerParams(_llamacppLib)));
  }
  
  @pragma("vm:prefer-inline")
  static ffi.Pointer<ffi.Char> _dart2ffi(String str) {
    return str.toNativeUtf8().cast<ffi.Char>();
  }

  String _ffi2dart(ffi.Pointer<ffi.Char> ptr) {
    final String dartString = ptr.cast<Utf8>().toDartString();
    _llamacppLib.free_string(ptr);
    return dartString;
  }
}

class ModelConfig {
  /// Number of model layers to run on the GPU VRAM (greatly improves 
  /// performance to run as many layers on GPU as possible)
  int gpuLayers = 99;
  /// Use memory mapping
  bool? useMemoryMapping;
  /// Force system to keep model in RAM
  bool? lockModelInRam;  

  avarex_llama.llama_model_params _getLlamaModelParams(avarex_llama.AvarexLlamaBindings llamacppLib) {
    var modelParams = llamacppLib.get_default_model_params();
    modelParams.n_gpu_layers = gpuLayers;
    modelParams.use_mmap = useMemoryMapping ?? modelParams.use_mmap;
    modelParams.use_mlock = lockModelInRam ?? modelParams.use_mlock;
    return modelParams;
  }
}

class ContextConfig {
  /// Max number of text context tokens
  int? maxTokenCount;
  /// Logical max batch size to submit to llama decode
  int? logicalMaxBatchSize;
  /// Physical maximum batch size
  int? physicalMaxBatchSize;
  /// max number of sequences (i.e. distinct states for recurrent models)
  int? maxSequences;
  /// Number of threads to use for generation
  int? genThreadCount;
  /// Number of threads to use for batch processing
  int? batchThreadCount;
  /// Performance timings enabled
  bool? performanceTimings;

  avarex_llama.llama_context_params _getLlamaContextParams(avarex_llama.AvarexLlamaBindings llamacppLib) {
    var ctxParams = llamacppLib.get_default_context_params();
    ctxParams.n_ctx = maxTokenCount ?? ctxParams.n_ctx;
    ctxParams.n_batch = logicalMaxBatchSize ?? ctxParams.n_batch;
    ctxParams.n_ubatch = physicalMaxBatchSize ?? ctxParams.n_ubatch;
    ctxParams.n_seq_max = maxSequences ?? ctxParams.n_seq_max;
    ctxParams.n_threads = genThreadCount ?? ctxParams.n_threads;
    ctxParams.n_threads_batch = batchThreadCount ?? ctxParams.n_threads_batch;
    ctxParams.no_perf = !(performanceTimings ?? !ctxParams.no_perf);
    return ctxParams;
  }
}

class SamplerConfig {
  /// Performance timings enabled
  bool? performanceTimings;

  avarex_llama.llama_sampler_chain_params _getLlamaSamplerParams(avarex_llama.AvarexLlamaBindings llamacppLib) {
    var samplerParams = llamacppLib.get_default_sampler_params();
    samplerParams.no_perf = !(performanceTimings ?? !samplerParams.no_perf);
    return samplerParams;
  }
}