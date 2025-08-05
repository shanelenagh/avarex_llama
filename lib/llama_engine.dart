import 'dart:ffi' as ffi;
// ignore: depend_on_referenced_packages (used as a string extension)
import 'package:ffi/ffi.dart';
import 'package:avarex_llama/avarex_llama_bindings_generated.dart' as avarex_llama;
import 'package:logging/logging.dart';

class LlamaEngine {

  final _log = Logger((LlamaEngine).toString());
  final avarex_llama.AvarexLlamaBindings _llamacppLib = avarex_llama.AvarexLlamaBindings(ffi.DynamicLibrary.open("llama.dll"));

  LlamaEngine(String modelPath, ffi.Pointer<avarex_llama.llama_model_params>? modelParams) {   
    _log.info("Starting llama.cpp with model $modelPath...");
    _llamacppLib.start_llama(_dart2ffi(modelPath), modelParams ?? ffi.nullptr);
    _log.info("Started llama.cpp");
  }

  String runGeneration(String prompt, int nPredict, ffi.Pointer<avarex_llama.llama_context_params>? contextParams, ffi.Pointer<avarex_llama.llama_sampler_chain_params>? samplerParams) {
    return _ffi2dart(_llamacppLib.run_generation(_dart2ffi(prompt), nPredict, contextParams ?? ffi.nullptr, samplerParams ?? ffi.nullptr));
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