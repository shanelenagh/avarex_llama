import 'package:avarex_llama/llama_engine.dart' as avarex_llama;

void main() {
  print("Starting llama...");
  final llama = avarex_llama.LlamaEngine("granite-3.3-2b-instruct-Q5_1.gguf");
  print("Started llama");
  final String answer = llama.runGeneration("What height does class A airspace begin at?", 20);
  print("Got Answer in Dart/Flutter: ${answer}");
}