enum Environment {
  local,
  dev,
  prod,
}

class EnvConfig {
  final Environment environment;
  final String baseUrl;
  final String websocketUrl;

  EnvConfig({
    required this.environment,
    required this.baseUrl,
    required this.websocketUrl,
  });

  static late EnvConfig _instance;

  static void instantiate({
    required Environment environment,
    required String baseUrl,
    required String websocketUrl,
  }) {
    _instance = EnvConfig(
      environment: environment,
      baseUrl: baseUrl,
      websocketUrl: websocketUrl,
    );
  }

  static EnvConfig get instance => _instance;
}
