import 'dart:ffi';
import 'package:avarex_llama/avarex_llama_bindings_generated.dart' as avarex_llama;
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final summer = avarex_llama.AvarexLlamaBindings(DynamicLibrary.open(
    p.join(p.current, "llama.dll")));
  final sumResult = summer.sum(1, 2);
  stdout.write("Hi: "+sumResult.toString());
  stdout.write("Starting llama...");
  summer.start_llama();
  stdout.write("Started llama");
}