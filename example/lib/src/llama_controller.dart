import 'package:vaden/vaden.dart';
import 'package:dllama/llama_engine.dart' as dllama;
import 'package:logging/logging.dart';

@Api(tag: 'Llama', description: 'Llama LLM Service')
@Controller('/llama')
class LlamaController {

  static dllama.LlamaEngine? _llama;
  final log = Logger((LlamaController).toString());

  LlamaController(ApplicationSettings settings) {
    if (_llama == null) {
      log.info("Starting load of LlamaEngine with model [${settings['aiModels']['llm']}]");
      _llama = dllama.LlamaEngine(settings["aiModels"]["llm"], null);
      log.info("LlamaEngine finished loading model [${settings['aiModels']['llm']}]");
    }
  }

  @Get('/ask')
  @ApiOperation(summary: 'Ask the LLM a question', description: 'Send a question to the LLM and receive a response.')
  String ask(@Query() @ApiQuery(description: "Question to ask the LLM (i.e., prompt)") question,
      {@Query() @ApiQuery(description: "Maximum number of tokens to generate in the response") int maxTokens = 1000}) {
    return _llama?.runGeneration(question, maxTokens, null, null) ?? "";
  }
}