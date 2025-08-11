import 'package:vaden/vaden.dart';
import 'package:avarex_llama/llama_engine.dart' as avarex_llama;

@Api(tag: 'Llama', description: 'Llama LLM Service')
@Controller('/llama')
class LlamaController {
  static final avarex_llama.LlamaEngine llama =  avarex_llama.LlamaEngine("granite-3.3-2b-instruct-Q5_1.gguf", null);

  @Get('/ask')
  String ask(@Query('question') String question) {
    return llama.runGeneration(question, 1000, null, null);
  }
}