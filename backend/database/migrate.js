const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
const { env } = require('../src/config/env');
const { logger } = require('../src/utils/logger');

async function migrate() {
  logger.info('Starting database migration...');
  
  // Ensure database exists
  const adminConn = await mysql.createConnection({
    host: env.DB_HOST,
    port: env.DB_PORT,
    user: env.DB_USER,
    password: env.DB_PASSWORD,
    multipleStatements: true,
  });

  await adminConn.query(`CREATE DATABASE IF NOT EXISTS \`${env.DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`);
  await adminConn.end();

  // Connect to DB and run schema
  const conn = await mysql.createConnection({
    host: env.DB_HOST,
    port: env.DB_PORT,
    user: env.DB_USER,
    password: env.DB_PASSWORD,
    database: env.DB_NAME,
    multipleStatements: true,
  });

  const sql = fs.readFileSync(path.join(__dirname, 'init.sql'), 'utf-8');
  await conn.query(sql);
  await conn.end();

  logger.info('✅ Database schema migration completed successfully!');
}

if (require.main === module) {
  migrate()
    .then(() => process.exit(0))
    .catch((err) => {
      logger.error('Migration failed:', err);
      process.exit(1);
    });
}

module.exports = { migrate };
