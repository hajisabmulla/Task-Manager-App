const { AppError } = require('../utils/app-error');

function validate(schema, source = 'body') {
  return (req, res, next) => {
    const result = schema.safeParse(req[source]);
    if (!result.success) {
      const formattedErrors = {};
      result.error.errors.forEach((err) => {
        const field = err.path.join('.') || 'general';
        if (!formattedErrors[field]) {
          formattedErrors[field] = err.message;
        }
      });
      return next(
        AppError.unprocessableEntity(
          'Validation failed. Please check the provided input.',
          formattedErrors
        )
      );
    }
    req[source] = result.data;
    next();
  };
}

module.exports = { validate };
