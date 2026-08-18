import 'dart:async';

/// Servicio global singleton que emite eventos cuando la sesión es invalidada
/// por el backend (otro dispositivo inició sesión con la misma cuenta).
/// 
/// El ErrorLink en GraphQLService publica aquí, y main.dart lo escucha
/// para forzar el cierre de sesión y navegar a la pantalla de login.
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  final StreamController<String> _sessionInvalidatedController =
      StreamController<String>.broadcast();

  Stream<String> get onSessionInvalidated =>
      _sessionInvalidatedController.stream;

  void notifySessionInvalidated(String reason) {
    _sessionInvalidatedController.add(reason);
  }

  void dispose() {
    _sessionInvalidatedController.close();
  }
}
