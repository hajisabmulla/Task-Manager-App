const { AppError } = require('../utils/app-error');

function notFoundHandler(req, res, next) {
  next(AppError.notFound(`Endpoint ${req.method} ${req.originalUrl} not found`, 'ROUTE_NOT_FOUND'));
}

module.exports = { notFoundHandler };
