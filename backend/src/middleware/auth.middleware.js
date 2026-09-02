const jwt = require('jsonwebtoken');
const { env } = require('../config/env');
const { AppError } = require('../utils/app-error');

function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(AppError.unauthorized('Authentication required. Missing Bearer token.', 'AUTH_TOKEN_MISSING'));
  }

  const token = authHeader.split(' ')[1];
  if (!token) {
    return next(AppError.unauthorized('Authentication required. Token is empty.', 'AUTH_TOKEN_EMPTY'));
  }

  try {
    const decoded = jwt.verify(token, env.JWT_ACCESS_SECRET);
    req.user = {
      id: decoded.id,
      email: decoded.email,
      name: decoded.name,
    };
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return next(AppError.unauthorized('Access token has expired', 'TOKEN_EXPIRED'));
    }
    return next(AppError.unauthorized('Invalid access token', 'TOKEN_INVALID'));
  }
}

module.exports = { authenticate };
