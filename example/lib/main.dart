import 'package:avarex_llama/llama_engine.dart' as dllama;
import 'dart:io' as io;


void main(List<String> args) {
  if (args.length < 3 || !io.File(args[0]).existsSync() || int.tryParse(args[1]) == null || args[2].isEmpty) { 
    io.stderr.writeln('Usage: main.dart <gguf_model_path> <max_number_of_tokens> <prompt/question>');
    io.exit(1);
  }

  final llama = dllama.LlamaEngine(args[0], null);
  io.stdout.writeln("Answer:\n${llama.runGeneration(args[2], int.parse(args[1]), null, null)}");
}