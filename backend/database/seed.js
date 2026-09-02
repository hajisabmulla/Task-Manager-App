const bcrypt = require('bcrypt');
const mysql = require('mysql2/promise');
const { env } = require('../src/config/env');
const { logger } = require('../src/utils/logger');
const { AppConstants } = require('../src/config/constants');

async function seed() {
  logger.info('Starting database seed...');

  const conn = await mysql.createConnection({
    host: env.DB_HOST,
    port: env.DB_PORT,
    user: env.DB_USER,
    password: env.DB_PASSWORD,
    database: env.DB_NAME,
  });

  try {
    const defaultPassword = 'password123';
    const passwordHash = await bcrypt.hash(defaultPassword, AppConstants.PASSWORD.SALT_ROUNDS);

    // Seed 4 team members safely without wiping existing users
    const users = [
      { name: 'Alex Johnson', email: 'alex@example.com' },
      { name: 'Sarah Connor', email: 'sarah@example.com' },
      { name: 'David Smith', email: 'david@example.com' },
      { name: 'Emily Davis', email: 'emily@example.com' },
    ];

    const insertedUserIds = [];
    for (const u of users) {
      const [existing] = await conn.query('SELECT id FROM users WHERE email = ?', [u.email]);
      if (existing.length > 0) {
        insertedUserIds.push(existing[0].id);
      } else {
        const [res] = await conn.query(
          'INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)',
          [u.name, u.email, passwordHash]
        );
        insertedUserIds.push(res.insertId);
      }
    }

    logger.info(`Verified seed users (total 4 users active).`);

    // Helper for relative date strings (YYYY-MM-DD)
    const getDate = (offsetDays) => {
      const d = new Date();
      d.setDate(d.getDate() + offsetDays);
      const year = d.getFullYear();
      const month = String(d.getMonth() + 1).padStart(2, '0');
      const day = String(d.getDate()).padStart(2, '0');
      return `${year}-${month}-${day}`;
    };

    // Seed 8 default tasks if not already existing
    const tasks = [
      {
        title: 'Design Authentication Architecture',
        description: 'Set up JWT, refresh token rotation, and bcrypt password hashing for all client requests.',
        status: 'DONE',
        assignee_id: insertedUserIds[0],
        created_by_id: insertedUserIds[0],
        due_date: getDate(-2),
      },
      {
        title: 'Implement Task API Endpoints',
        description: 'Build REST endpoints for Task CRUD operations, filtering by status, search by title, and pagination.',
        status: 'DONE',
        assignee_id: insertedUserIds[1],
        created_by_id: insertedUserIds[0],
        due_date: getDate(0),
      },
      {
        title: 'Build Flutter BLoC State Management',
        description: 'Implement AuthBloc, TaskBloc, and TeamBloc to ensure complete separation of UI and business logic.',
        status: 'IN_PROGRESS',
        assignee_id: insertedUserIds[2],
        created_by_id: insertedUserIds[0],
        due_date: getDate(2),
      },
      {
        title: 'Integrate Dio Automatic Token Refresh',
        description: 'Configure Dio interceptor to seamlessly handle 401 Unauthorized by calling /api/auth/refresh and retrying failed requests.',
        status: 'IN_PROGRESS',
        assignee_id: insertedUserIds[0],
        created_by_id: insertedUserIds[1],
        due_date: getDate(3),
      },
      {
        title: 'Develop Responsive Task List & Filter UI',
        description: 'Create an engaging, clean Material 3 UI with status filter tabs, search debouncing, and pull-to-refresh.',
        status: 'TODO',
        assignee_id: insertedUserIds[3],
        created_by_id: insertedUserIds[2],
        due_date: getDate(5),
      },
      {
        title: 'Create Team Member Overview Screen',
        description: 'List all team members with their initials avatar, email, and task assignment capabilities.',
        status: 'TODO',
        assignee_id: insertedUserIds[1],
        created_by_id: insertedUserIds[2],
        due_date: getDate(7),
      },
      {
        title: 'Input Validation & Security Hardening',
        description: 'Verify password complexity rules, alpha-only names, RFC email checks, Helmet security headers, and rate limiting.',
        status: 'TODO',
        assignee_id: insertedUserIds[2],
        created_by_id: insertedUserIds[3],
        due_date: getDate(9),
      },
      {
        title: 'End-to-End Testing & Documentation',
        description: 'Perform complete E2E testing of signup, login, task management, and token refresh flow, and write comprehensive README.',
        status: 'TODO',
        assignee_id: insertedUserIds[3],
        created_by_id: insertedUserIds[0],
        due_date: getDate(12),
      },
    ];

    for (const t of tasks) {
      const [existingTask] = await conn.query(
        'SELECT id FROM tasks WHERE title = ? AND created_by_id = ?',
        [t.title, t.created_by_id]
      );
      if (existingTask.length === 0) {
        await conn.query(
          'INSERT INTO tasks (title, description, status, assignee_id, created_by_id, due_date) VALUES (?, ?, ?, ?, ?, ?)',
          [t.title, t.description, t.status, t.assignee_id, t.created_by_id, t.due_date]
        );
      }
    }

    logger.info('Database seed complete without deleting custom user data.');
  } finally {
    await conn.end();
  }
}

if (require.main === module) {
  seed()
    .then(() => {
      logger.info('✅ Database seed completed successfully!');
      process.exit(0);
    })
    .catch((err) => {
      logger.error('Seed failed:', err);
      process.exit(1);
    });
}

module.exports = { seed };
