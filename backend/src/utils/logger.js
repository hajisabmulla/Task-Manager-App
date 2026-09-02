const { env } = require('../config/env');

const logger = {
  info: (msg, ...args) => {
    if (env.NODE_ENV !== 'test') {
      console.log(`[INFO] ${new Date().toISOString()} - ${msg}`, ...args);
    }
  },
  warn: (msg, ...args) => {
    if (env.NODE_ENV !== 'test') {
      console.warn(`[WARN] ${new Date().toISOString()} - ${msg}`, ...args);
    }
  },
  error: (msg, ...args) => {
    console.error(`[ERROR] ${new Date().toISOString()} - ${msg}`, ...args);
  },
  debug: (msg, ...args) => {
    if (env.NODE_ENV === 'development') {
      console.debug(`[DEBUG] ${new Date().toISOString()} - ${msg}`, ...args);
    }
  },
};

module.exports = { logger };
