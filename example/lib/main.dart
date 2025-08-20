import 'package:dllama/llama_engine.dart' as dllama;
import 'dart:io' as io;


void main(List<String> args) {
  if (args.length < 2 || !io.File(args[0]).existsSync() || int.tryParse(args[1]) == null) { 
    io.stderr.writeln('Usage: main.dart <gguf_model_path> <max_number_of_tokens> [<prompt/question>]');
    io.exit(1);
  }

  final llama = dllama.LlamaEngine(args[0], null);
  if (args.length > 2) {
    io.stdout.writeln("Answer:\n${llama.runGeneration(args[2], int.parse(args[1]), null, null)}");
  } else {
    String? prompt;
    while(true) {
      io.stdout.write("Enter question/prompt: ");
      prompt = io.stdin.readLineSync();
      if (prompt != null && prompt.trim().isNotEmpty) {
        io.stdout.writeln("Response:\n${llama.runGeneration(prompt, int.parse(args[1]), null, null)}");
      } else {
        break;
      }
    }
  }
}