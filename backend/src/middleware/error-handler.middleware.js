const { failure } = require('../utils/api-response');
const { logger } = require('../utils/logger');
const { env } = require('../config/env');

function errorHandler(err, req, res, next) {
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal Server Error';
  let code = err.code || 'INTERNAL_ERROR';
  let errors = err.errors || null;

  // Handle MySQL errors
  if (err.code === 'ER_DUP_ENTRY') {
    statusCode = 409;
    code = 'DUPLICATE_RESOURCE';
    message = 'A resource with this identifier already exists';
  } else if (err.code === 'ER_NO_REFERENCED_ROW_2') {
    statusCode = 400;
    code = 'INVALID_REFERENCE';
    message = 'Referenced entity (e.g. assignee) does not exist';
  }

  // Handle JSON parse error from express.json()
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    statusCode = 400;
    code = 'INVALID_JSON';
    message = 'Malformed JSON in request body';
  }

  if (statusCode >= 500) {
    logger.error(`[${req.method} ${req.originalUrl}] Unhandled Error:`, err);
  } else {
    logger.warn(`[${req.method} ${req.originalUrl}] Client Error (${statusCode}):`, message);
  }

  const responseBody = failure(message, code, errors);

  if (env.NODE_ENV === 'development' && statusCode >= 500) {
    responseBody.stack = err.stack;
  }

  res.status(statusCode).json(responseBody);
}

module.exports = { errorHandler };
