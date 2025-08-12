import 'package:vaden/vaden.dart';
import 'package:avarex_llama/llama_engine.dart' as avarex_llama;
import 'package:logging/logging.dart';

@Api(tag: 'Llama', description: 'Llama LLM Service')
@Controller('/llama')
class LlamaController {

  static avarex_llama.LlamaEngine? _llama;
  final log = Logger((LlamaController).toString());

  LlamaController(ApplicationSettings settings) {
    if (_llama == null) {
      log.info("Starting load of LlamaEngine with model [${settings['aiModels']['llm']}]");
      _llama = avarex_llama.LlamaEngine(settings["aiModels"]["llm"], null);
      log.info("LlamaEngine finished loading model [${settings['aiModels']['llm']}]");
    }
  }

  @Get('/ask')
  @ApiOperation(summary: 'Ask the LLM a question', description: 'Send a question to the LLM and receive a response.')
  String ask(@Query() @ApiQuery(description: "Question to ask the LLM (i.e., prompt)") question) {
    return _llama?.runGeneration(question, 1000, null, null) ?? "";
  }
}