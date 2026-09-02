function success(data = null, message = 'Success', pagination = null) {
  const response = {
    success: true,
    message,
  };

  if (data !== null && data !== undefined) {
    response.data = data;
  }

  if (pagination !== null && pagination !== undefined) {
    response.pagination = pagination;
  }

  return response;
}

function failure(message = 'An error occurred', code = 'ERROR', errors = null) {
  const response = {
    success: false,
    message,
    code,
  };

  if (errors !== null && errors !== undefined) {
    response.errors = errors;
  }

  return response;
}

module.exports = {
  success,
  failure,
};
