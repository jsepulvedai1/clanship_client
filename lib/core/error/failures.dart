import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure([this.message = 'An unexpected error occurred']);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  ServerFailure([String? message]) : super(_sanitizeMessage(message ?? 'An unexpected error occurred'));

  static String _sanitizeMessage(String msg) {
    final lower = msg.toLowerCase();
    
    // Check for internet connection errors
    if (lower.contains('socketexception') || 
        lower.contains('failed host lookup') || 
        lower.contains('network_error') || 
        lower.contains('connection failed') || 
        lower.contains('xmlhttprequest') ||
        lower.contains('connection refused') ||
        lower.contains('http status error [502]') ||
        lower.contains('http status error [503]') ||
        lower.contains('http status error [504]')) {
      return 'No se pudo conectar al servidor. Por favor, verifica tu conexión a internet.';
    }

    // Check for session/auth errors
    if (lower.contains('signature') || 
        lower.contains('jwt') || 
        lower.contains('token') || 
        lower.contains('auth') || 
        lower.contains('credentials')) {
      if (lower.contains('invalid credentials') || lower.contains('credenciales incorrectas') || lower.contains('incorrectas')) {
        return 'Credenciales incorrectas. Por favor, verifica tus datos.';
      }
      return 'Tu sesión ha expirado o es inválida. Por favor, vuelve a iniciar sesión.';
    }

    // Check for internal server error signatures or technical codes
    if (lower.contains('exception:') || 
        lower.contains('graphqlerror') || 
        lower.contains('serverexception') ||
        lower.contains('doesnotexist') || 
        lower.contains('field') || 
        lower.contains('attributeerror') || 
        lower.contains('typeerror') || 
        lower.contains('syntaxerror') ||
        lower.contains('internal server error') ||
        lower.contains('database') ||
        lower.contains('django') ||
        lower.contains('graphene') ||
        lower.contains('null') ||
        msg.contains('{') ||
        msg.contains('[') ||
        msg.contains('http') ||
        msg.length > 100) {
      return 'Lo sentimos, hubo un error inesperado.';
    }

    return msg;
  }
}

class CacheFailure extends Failure {
  const CacheFailure([super.message]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}
