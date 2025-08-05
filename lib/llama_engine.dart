import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:avarex_llama/avarex_llama_bindings_generated.dart' as avarex_llama;
import 'package:logger/logger.dart';
import 'package:charset/charset.dart'; // Import the charset package

class LlamaEngine {

  final Logger _log = Logger();
  avarex_llama.AvarexLlamaBindings _llamacppLib = avarex_llama.AvarexLlamaBindings(ffi.DynamicLibrary.open("llama.dll"));

  LlamaEngine(String model_path) {
    _log.i("Starting llama.cpp with model ${model_path}...");
    _llamacppLib.start_llama(_dart2ffi(model_path));
    _log.i("Started llama.cpp");
  }

  String runGeneration(String prompt, int n_predict) {
    return _ffi2dart(_llamacppLib.run_generation(_dart2ffi(prompt), n_predict));
  }
  
  //@pragma("vm:prefer-inline")
  static ffi.Pointer<ffi.Char> _dart2ffi(String str) {
    return str.toNativeUtf8().cast<ffi.Char>();
  }

  @pragma("vm:prefer-inline")
  static String _ffi2dart(ffi.Pointer<ffi.Char> ptr) {
      // TODO: Encoding problem here on Windows/etc, need to use charset package or something
      return ptr.cast<Utf8>().toDartString();
  }
}