import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:avarex_llama/avarex_llama_bindings_generated.dart' as avarex_llama;
import 'package:path/path.dart' as p;

void main() {
  final llamacpp_dll = avarex_llama.AvarexLlamaBindings(ffi.DynamicLibrary.open(p.join(p.current, "llama.dll")));
  print("Starting llama...");
  llamacpp_dll.start_llama("granite-3.3-2b-instruct-Q5_1.gguf".toNativeUtf8().cast<ffi.Char>());
  print("Started llama");
}