import 'package:avarex_llama_example/config/app_configuration.dart';
import 'package:vaden/vaden.dart';
import 'package:avarex_llama/llama_engine.dart' as avarex_llama;

@Api(tag: 'Llama', description: 'Llama LLM Service')
@Controller('/llama')
class LlamaController {

  static avarex_llama.LlamaEngine? _llama;

  LlamaController(ApplicationSettings settings) {
    _llama =  _llama ?? avarex_llama.LlamaEngine(settings["aiModels"]["llm"], null);
  }

  @Get('/ask')
  @ApiOperation(summary: 'Ask the LLM a question', description: 'Send a question to the LLM and receive a response.')
  String ask(@Query() @ApiQuery(description: "Question to ask the LLM (i.e., prompt)") question) {
    return _llama?.runGeneration(question, 1000, null, null) ?? "";
  }
}