// GENERATED CODE - DO NOT MODIFY BY HAND
// Aggregated Vaden application file
// ignore_for_file: prefer_function_declarations_over_variables, implementation_imports
import 'package:avarex_llama_example/config/app_configuration.dart';
import 'package:avarex_llama_example/config/app_controller_advice.dart';
import 'package:avarex_llama_example/config/openapi/openapi_configuration.dart';
import 'package:avarex_llama_example/config/openapi/openapi_controller.dart';
import 'package:avarex_llama_example/config/resources/resource_configuration.dart';
import 'package:avarex_llama_example/src/llama_controller.dart';

import 'dart:convert';
import 'dart:io';
import 'package:vaden/vaden.dart';

class VadenApp implements DartVadenApplication {
  final _router = Router();
  final _injector = AutoInjector();

  @override
  AutoInjector get injector => _injector;

  @override
  Router get router => _router;

  VadenApp();

  @override
  Future<HttpServer> run(List<String> args) async {
    _injector.tryGet<CommandLineRunner>()?.run(args);
    _injector.tryGet<ApplicationRunner>()?.run(this);
    final pipeline = _injector.get<Pipeline>();
    final handler = pipeline.addHandler((request) async {
      try {
        final response = await _router(request);
        return response;
      } catch (e, stack) {
        print(e);
        print(stack);
        return _handleException(e);
      }
    });

    final settings = _injector.get<ApplicationSettings>();
    final port = settings['server']['port'] ?? 8080;
    final host = settings['server']['host'] ?? '0.0.0.0';

    final server = await serve(handler, host, port);

    return server;
  }

  @override
  Future<void> setup() async {
    final paths = <String, dynamic>{};
    final apis = <Api>[];
    final asyncBeans = <Future<void> Function()>[];
    _injector.addLazySingleton<DSON>(_DSON.new);

    final configurationAppConfiguration = AppConfiguration();

    _injector.addLazySingleton(configurationAppConfiguration.settings);
    _injector.addLazySingleton(configurationAppConfiguration.globalMiddleware);

    _injector.addLazySingleton(AppControllerAdvice.new);

    final configurationOpenApiConfiguration = OpenApiConfiguration();

    _injector.addLazySingleton(configurationOpenApiConfiguration.openApi);
    _injector.addLazySingleton(configurationOpenApiConfiguration.swaggerUI);

    _injector.add(OpenAPIController.new);
    final routerOpenAPIController = Router();
    var pipelineOpenAPIControllergetSwagger = const Pipeline();
    final handlerOpenAPIControllergetSwagger = (Request request) async {
      final ctrl = _injector.get<OpenAPIController>();
      final result = await ctrl.getSwagger(request);
      return result;
    };
    routerOpenAPIController.get(
      '/',
      pipelineOpenAPIControllergetSwagger.addHandler(
        handlerOpenAPIControllergetSwagger,
      ),
    );
    var pipelineOpenAPIControllergetOpenApiJSON = const Pipeline();
    final handlerOpenAPIControllergetOpenApiJSON = (Request request) async {
      final ctrl = _injector.get<OpenAPIController>();
      final result = ctrl.getOpenApiJSON(request);
      return result;
    };
    routerOpenAPIController.get(
      '/openapi.json',
      pipelineOpenAPIControllergetOpenApiJSON.addHandler(
        handlerOpenAPIControllergetOpenApiJSON,
      ),
    );
    _router.mount('/docs', routerOpenAPIController.call);

    final configurationResourceConfiguration = ResourceConfiguration();

    _injector.addLazySingleton(
      configurationResourceConfiguration.configStorage,
    );
    _injector.addLazySingleton(configurationResourceConfiguration.resources);

    _injector.add(LlamaController.new);
    apis.add(const Api(tag: 'Llama', description: 'Llama LLM Service'));
    final routerLlamaController = Router();
    paths['/llama/ask'] = <String, dynamic>{
      ...paths['/llama/ask'] ?? <String, dynamic>{},
      'get': {
        'tags': ['Llama'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/llama/ask']['get']['summary'] = 'Ask the LLM a question';
    paths['/llama/ask']['get']['description'] =
        'Send a question to the LLM and receive a response.';
    var pipelineLlamaControllerask = const Pipeline();
    paths['/llama/ask']['get']['parameters']?.add({
      'name': 'question',
      'in': 'query',
      'required': true,
      'schema': {'type': 'string'},
    });

    final handlerLlamaControllerask = (Request request) async {
      if (request.url.queryParameters['question'] == null) {
        return Response(
          400,
          body: jsonEncode({'error': 'Query param is required (question)'}),
        );
      }
      final question = _parse<dynamic>(
        request.url.queryParameters['question'],
      )!;

      final ctrl = _injector.get<LlamaController>();
      final result = ctrl.ask(question);
      return Response.ok(result, headers: {'Content-Type': 'text/plain'});
    };
    routerLlamaController.get(
      '/ask',
      pipelineLlamaControllerask.addHandler(handlerLlamaControllerask),
    );
    _router.mount('/llama', routerLlamaController.call);

    _injector.addLazySingleton(OpenApiConfig.create(paths, apis).call);
    _injector.commit();

    for (final asyncBean in asyncBeans) {
      await asyncBean();
    }
  }

  Future<Response> _handleException(dynamic e) async {
    final controllerAdviceAppControllerAdvice = _injector
        .get<AppControllerAdvice>();
    if (e is ResponseException) {
      return await controllerAdviceAppControllerAdvice.handleResponseException(
        e,
      );
    }

    if (e is Exception) {
      return controllerAdviceAppControllerAdvice.handleException(e);
    }

    return Response.internalServerError(
      body: jsonEncode({'error': 'Internal server error'}),
    );
  }

  PType? _parse<PType>(String? value) {
    if (value == null) {
      return null;
    }

    if (PType == int) {
      return int.parse(value) as PType;
    } else if (PType == double) {
      return double.parse(value) as PType;
    } else if (PType == bool) {
      return bool.parse(value) as PType;
    } else {
      return value as PType;
    }
  }
}

class _DSON extends DSON {
  @override
  (
    Map<Type, FromJsonFunction>,
    Map<Type, ToJsonFunction>,
    Map<Type, ToOpenApiNormalMap>,
  )
  getMaps() {
    final fromJsonMap = <Type, FromJsonFunction>{};
    final toJsonMap = <Type, ToJsonFunction>{};
    final toOpenApiMap = <Type, ToOpenApiNormalMap>{};

    return (fromJsonMap, toJsonMap, toOpenApiMap);
  }
}
