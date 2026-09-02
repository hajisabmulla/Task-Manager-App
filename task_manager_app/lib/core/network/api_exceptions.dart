class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.errors,
  });

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException({
    super.message =
        'Cannot connect to server. Please check your network connection.',
  }) : super(statusCode: 0, code: 'NETWORK_ERROR');
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({
    super.message = 'Session expired or unauthorized. Please log in again.',
  }) : super(statusCode: 401, code: 'UNAUTHORIZED');
}

class ValidationException extends ApiException {
  ValidationException({
    super.message = 'Validation failed. Please correct the errors.',
    super.errors,
  }) : super(statusCode: 422, code: 'VALIDATION_ERROR');
}
