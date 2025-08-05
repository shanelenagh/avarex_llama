import 'package:avarex_llama/llama_engine.dart' as avarex_llama;
import 'package:logging/logging.dart';

final log = Logger("avarex_llama_example");

void main() {
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.time} ${record.level.name} ${record.loggerName} - ${record.message}');
  });
  log.info("Starting llama...");
  final llama = avarex_llama.LlamaEngine("granite-3.3-2b-instruct-Q5_1.gguf");
  log.info("Started llama");
  final String answer = llama.runGeneration("What height does class A airspace begin at?", 20);
  log.info("Got Answer in Dart/Flutter: $answer");
}