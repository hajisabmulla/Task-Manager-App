const TaskStatus = Object.freeze({
  TODO: 'TODO',
  IN_PROGRESS: 'IN_PROGRESS',
  DONE: 'DONE',
});

const ValidTaskStatuses = Object.values(TaskStatus);

const AppConstants = Object.freeze({
  PAGINATION: {
    DEFAULT_PAGE: 1,
    DEFAULT_LIMIT: 20,
    MAX_LIMIT: 100,
  },
  PASSWORD: {
    MIN_LENGTH: 8,
    SALT_ROUNDS: 10,
  },
  NAME: {
    MIN_LENGTH: 3,
    MAX_LENGTH: 50,
  },
});

module.exports = {
  TaskStatus,
  ValidTaskStatuses,
  AppConstants,
};
