const { createServer } = require('http');
const { createApp } = require('./app');
const { env } = require('./config/env');
const { logger } = require('./utils/logger');
const { getPool, disconnectDatabase } = require('./config/database');

async function startServer() {
  try {
    // Ensure database pool is connected and ready
    await getPool();
    logger.info('Connected to MySQL Database Pool successfully.');

    const app = createApp();
    const server = createServer(app);

    server.listen(env.PORT, () => {
      logger.info(`🚀 Task Manager Backend Server is running on http://localhost:${env.PORT}`);
      logger.info(`Environment: ${env.NODE_ENV}`);
    });

    // Graceful Shutdown
    async function shutdown(signal) {
      logger.info(`Received ${signal}. Shutting down gracefully...`);
      server.close(async () => {
        logger.info('HTTP server closed.');
        await disconnectDatabase();
        logger.info('Database pool closed. Exiting process.');
        process.exit(0);
      });

      // Force exit after 5 seconds if still hanging
      setTimeout(() => {
        logger.error('Forcefully exiting due to timeout during shutdown.');
        process.exit(1);
      }, 5000).unref();
    }

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));
  } catch (err) {
    logger.error('Fatal error during server startup:', err);
    process.exit(1);
  }
}

if (require.main === module) {
  startServer();
}

module.exports = { startServer };
