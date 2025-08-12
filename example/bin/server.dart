import 'package:avarex_llama_example/vaden_application.dart';
import 'package:logging/logging.dart';

final log = Logger("avarex_llama_example:server");

Future<void> main(List<String> args) async {
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.time} ${record.level.name} ${record.loggerName} - ${record.message}');
  });  
  final vaden = VadenApp();
  await vaden.setup();
  log.info("Starting Vaden server...");
  final server = await vaden.run(args);
  log.info('Server listening at port ${server.port} (go to /docs path for Swagger/OpenAPI UI to test it out)');
}

