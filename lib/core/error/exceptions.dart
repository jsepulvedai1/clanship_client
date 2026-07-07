class ServerException implements Exception {
  final String message;
  ServerException({this.message = 'A server error occurred'});
}

class CacheException implements Exception {
  final String message;
  CacheException({this.message = 'A cache error occurred'});
}

class ValidationException implements Exception {
  final String message;
  ValidationException({this.message = 'A validation error occurred'});
}
