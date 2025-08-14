import 'dart:ffi' as ffi;
// ignore: depend_on_referenced_packages (used as a string extension)
import 'package:ffi/ffi.dart';
import 'package:logging/logging.dart';
import 'dart:io';
import 'dart:isolate';
import 'dart:async';

import 'package:dllama/dllama_bindings_generated.dart' as dllama;

final dllama.DllamaBindings _llamacppLib = () {
    if (Platform.isWindows) {
      return dllama.DllamaBindings(ffi.DynamicLibrary.open("dllama.dll"));
    } else if (Platform.isLinux || Platform.isAndroid) {
      return dllama.DllamaBindings(ffi.DynamicLibrary.open("dllama.so"));
    } else if (Platform.isMacOS || Platform.isIOS) {
      return dllama.DllamaBindings(ffi.DynamicLibrary.open("dllama.framework/dllama"));
    } else {
      throw Exception('Dllama LlamaCPP Unsupported Platform');
    } 
}();

class LlamaEngine {

  final _log = Logger((LlamaEngine).toString());

  LlamaEngine(String modelPath, ModelConfig? modelConfig) {   
    _log.info("Starting llama.cpp with model $modelPath...");
    _llamacppLib.start_llama(_dart2ffi(modelPath), (modelConfig??ModelConfig())._getLlamaModelParams(_llamacppLib));
    _log.info("Started llama.cpp");
  }

  String runGeneration(String prompt, int nPredict, ContextConfig? contextConfig, SamplerConfig? samplerConfig) {
    return _ffi2dart(_llamacppLib.run_generation(_dart2ffi(prompt), nPredict, 
      (contextConfig??ContextConfig())._getLlamaContextParams(_llamacppLib), (samplerConfig??SamplerConfig())._getLlamaSamplerParams(_llamacppLib)));
  }

  Future<String> runGenerationAsync(String prompt, int nPredict, ContextConfig? contextConfig, SamplerConfig? samplerConfig) async {
    final SendPort helperIsolateSendPort = await _helperIsolateSendPort;
    final int requestId = _nextRunGenerationRequestId++;
    final _RunGenerationRequest request = _RunGenerationRequest(requestId, _dart2ffi(prompt), nPredict, 
      (contextConfig??ContextConfig())._getLlamaContextParams(_llamacppLib), (samplerConfig??SamplerConfig())._getLlamaSamplerParams(_llamacppLib));
    final Completer<String> completer = Completer<String>();
    _runGenerationRequests[requestId] = completer;
    helperIsolateSendPort.send(request);
    return completer.future;
  }  
  
  @pragma("vm:prefer-inline")
  static ffi.Pointer<ffi.Char> _dart2ffi(String str) {
    return str.toNativeUtf8().cast<ffi.Char>();
  }

  static String _ffi2dart(ffi.Pointer<ffi.Char> ptr) {
    final String dartString = ptr.cast<Utf8>().toDartString();
    _llamacppLib.free_string(ptr);
    return dartString;
  }
}

class ModelConfig {
  /// Number of model layers to run on the GPU VRAM (greatly improves 
  /// performance to run as many layers on GPU as possible)
  int gpuLayers = 99;
  /// Use memory mapping
  bool? useMemoryMapping;
  /// Force system to keep model in RAM
  bool? lockModelInRam;  

  dllama.llama_model_params _getLlamaModelParams(dllama.DllamaBindings llamacppLib) {
    var modelParams = llamacppLib.get_default_model_params();
    modelParams.n_gpu_layers = gpuLayers;
    modelParams.use_mmap = useMemoryMapping ?? modelParams.use_mmap;
    modelParams.use_mlock = lockModelInRam ?? modelParams.use_mlock;
    return modelParams;
  }
}

class ContextConfig {
  /// Max number of text context tokens
  int? maxTokenCount;
  /// Physical maximum batch size
  int? physicalMaxBatchSize;
  /// max number of sequences (i.e. distinct states for recurrent models)
  int? maxSequences;
  /// Number of threads to use for generation
  int? genThreadCount;
  /// Number of threads to use for batch processing
  int? batchThreadCount;
  /// Performance timings enabled
  bool? performanceTimings;

  dllama.llama_context_params _getLlamaContextParams(dllama.DllamaBindings llamacppLib) {
    var ctxParams = llamacppLib.get_default_context_params();
    ctxParams.n_ctx = maxTokenCount ?? ctxParams.n_ctx;
    ctxParams.n_ubatch = physicalMaxBatchSize ?? ctxParams.n_ubatch;
    ctxParams.n_seq_max = maxSequences ?? ctxParams.n_seq_max;
    ctxParams.n_threads = genThreadCount ?? ctxParams.n_threads;
    ctxParams.n_threads_batch = batchThreadCount ?? ctxParams.n_threads_batch;
    ctxParams.no_perf = !(performanceTimings ?? !ctxParams.no_perf);
    return ctxParams;
  }
}

class SamplerConfig {
  /// Performance timings enabled
  bool? performanceTimings;

  dllama.llama_sampler_chain_params _getLlamaSamplerParams(dllama.DllamaBindings llamacppLib) {
    var samplerParams = llamacppLib.get_default_sampler_params();
    samplerParams.no_perf = !(performanceTimings ?? !samplerParams.no_perf);
    return samplerParams;
  }
}


/*
 * Async support
 */

/// An async request to 'runGeneration'.
class _RunGenerationRequest {
  final int id;
  final ffi.Pointer<ffi.Char> prompt;
  final int numPredict;
  final dllama.llama_context_params contextParams;
  final dllama.llama_sampler_chain_params samplerParams;

  const _RunGenerationRequest(this.id, this.prompt, this.numPredict, this.contextParams, this.samplerParams);
}

/// An async response with the result of `runGeneration`.
class _RunGenerationResponse {
  final int id;
  final String result;

  const _RunGenerationResponse(this.id, this.result);
}

/// Async request ID counter
int _nextRunGenerationRequestId = 0;

/// Mapping from [_RunGenerationResponse] `id`s to the completers corresponding to the correct future of the pending request.
final Map<int, Completer<String>> _runGenerationRequests = <int, Completer<String>>{};

/// The SendPort belonging to the helper isolate.
Future<SendPort> _helperIsolateSendPort = () async {
  // The helper isolate is going to send us back a SendPort, which we want to
  // wait for.
  final Completer<SendPort> completer = Completer<SendPort>();

  // Receive port on the main isolate to receive messages from the helper.
  // We receive two types of messages:
  // 1. A port to send messages on.
  // 2. Responses to requests we sent.
  final ReceivePort receivePort = ReceivePort()
    ..listen((dynamic data) {
      if (data is SendPort) {
        // The helper isolate sent us the port on which we can sent it requests.
        completer.complete(data);
        return;
      }
      if (data is _RunGenerationResponse) {
        // The helper isolate sent us a response to a request we sent.
        final Completer<String> completer = _runGenerationRequests[data.id]!;
        _runGenerationRequests.remove(data.id);
        completer.complete(data.result);
        return;
      }
      throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
    });

  // Start the helper isolate.
  await Isolate.spawn((SendPort sendPort) async {
    final ReceivePort helperReceivePort = ReceivePort()
      ..listen((dynamic data) {
        // On the helper isolate listen to requests and respond to them.
        if (data is _RunGenerationRequest) {
          final ffi.Pointer<ffi.Char> result = _llamacppLib.run_generation(data.prompt, data.numPredict, data.contextParams, data.samplerParams);
          final _RunGenerationResponse response = _RunGenerationResponse(data.id, LlamaEngine._ffi2dart(result));
          sendPort.send(response);
          return;
        }
        throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
      });

    // Send the port to the main isolate on which we can receive requests.
    sendPort.send(helperReceivePort.sendPort);
  }, receivePort.sendPort);

  // Wait until the helper isolate has sent us back the SendPort on which we
  // can start sending requests.
  return completer.future;
}();