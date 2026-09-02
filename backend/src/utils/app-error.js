class AppError extends Error {
  constructor(message, statusCode = 500, code = 'INTERNAL_ERROR', errors = null) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.errors = errors;
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }

  static badRequest(message = 'Bad Request', code = 'BAD_REQUEST', errors = null) {
    return new AppError(message, 400, code, errors);
  }

  static unauthorized(message = 'Unauthorized', code = 'UNAUTHORIZED') {
    return new AppError(message, 401, code);
  }

  static forbidden(message = 'Forbidden', code = 'FORBIDDEN') {
    return new AppError(message, 403, code);
  }

  static notFound(message = 'Resource not found', code = 'NOT_FOUND') {
    return new AppError(message, 404, code);
  }

  static conflict(message = 'Resource conflict', code = 'CONFLICT') {
    return new AppError(message, 409, code);
  }

  static unprocessableEntity(message = 'Validation failed', errors = null) {
    return new AppError(message, 422, 'VALIDATION_ERROR', errors);
  }

  static internal(message = 'Internal Server Error') {
    return new AppError(message, 500, 'INTERNAL_SERVER_ERROR');
  }
}

module.exports = { AppError };
