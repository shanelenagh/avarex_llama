import 'package:vaden/vaden.dart';
import 'dart:io';

@Configuration()
class AppConfiguration {
  @Bean()
  ApplicationSettings settings() {
    if (!File('application.yaml').existsSync()) {
      File("application.yaml").writeAsStringSync("server:\n  port: 8080\nopenapi:\n  enable: true");
    }
    return ApplicationSettings.load('application.yaml');
  }

  @Bean()
  Pipeline globalMiddleware(ApplicationSettings settings) {
    return Pipeline() //
        .addMiddleware(cors(allowedOrigins: ['*']))
        .addVadenMiddleware(EnforceJsonContentType())
        .addMiddleware(logRequests());
  }
}
