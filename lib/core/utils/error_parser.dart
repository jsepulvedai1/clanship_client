import 'package:graphql_flutter/graphql_flutter.dart';

const String _defaultErrorMessage = 'Lo sentimos, hubo un error. Por favor, intenta de nuevo.';

String getCleanErrorMessage(dynamic e) {
  if (e is OperationException) {
    if (e.graphqlErrors.isNotEmpty) {
      return _sanitizeForUser(e.graphqlErrors.first.message);
    }
    if (e.linkException != null) {
      return 'Error de conexión con el servidor. Por favor verifica tu internet.';
    }
  }
  if (e is String) {
    return _sanitizeForUser(e);
  }
  return _defaultErrorMessage;
}

/// Sanitizes any error string to ensure no technical details leak to the user.
String sanitizeErrorForUser(String message) {
  return _sanitizeForUser(message);
}

String _sanitizeForUser(String msg) {
  final lower = msg.toLowerCase();
  
  if (lower.contains('socketexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('network_error') ||
      lower.contains('connection failed') ||
      lower.contains('connection refused') ||
      lower.contains('xmlhttprequest')) {
    return 'No se pudo conectar al servidor. Por favor, verifica tu conexión a internet.';
  }

  if (lower.contains('jwt') ||
      lower.contains('token') ||
      lower.contains('signature') ||
      lower.contains('credentials')) {
    return 'Tu sesión ha expirado. Por favor, vuelve a iniciar sesión.';
  }

  if (lower.contains('exception:') ||
      lower.contains('graphqlerror') ||
      lower.contains('serverexception') ||
      lower.contains('typeerror') ||
      lower.contains('syntaxerror') ||
      lower.contains('attributeerror') ||
      lower.contains('doesnotexist') ||
      lower.contains('internal server error') ||
      lower.contains('database') ||
      lower.contains('django') ||
      lower.contains('graphene') ||
      lower.contains('null') ||
      lower.contains('stacktrace') ||
      lower.contains('traceback') ||
      msg.contains('{') ||
      msg.contains('[') ||
      msg.contains('http') ||
      msg.length > 120) {
    return _defaultErrorMessage;
  }

  if (msg.startsWith('Exception: ')) {
    return _sanitizeForUser(msg.substring(11));
  }

  return msg;
}
