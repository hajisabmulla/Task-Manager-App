process.env.NODE_ENV = 'test';
process.env.DB_NAME = 'task_manager_test_db';

const assert = require('assert');
const http = require('http');
const mysql = require('mysql2/promise');
const { env } = require('../src/config/env');
const { createApp } = require('../src/app');
const { migrate } = require('../database/migrate');
const { seed } = require('../database/seed');
const { disconnectDatabase } = require('../src/config/database');

// Helper to make HTTP requests
function request(server, options, body = null) {
  return new Promise((resolve, reject) => {
    const port = server.address().port;
    const reqOptions = {
      hostname: '127.0.0.1',
      port,
      path: options.path,
      method: options.method || 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...(options.headers || {}),
      },
    };

    const req = http.request(reqOptions, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          const parsed = data ? JSON.parse(data) : {};
          resolve({ status: res.statusCode, headers: res.headers, body: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, headers: res.headers, body: data });
        }
      });
    });

    req.on('error', reject);

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

async function runTests() {
  console.log('🧪 Starting Backend API Integration Tests...\n');

  // Reset isolated test database
  const adminConn = await mysql.createConnection({
    host: env.DB_HOST,
    port: env.DB_PORT,
    user: env.DB_USER,
    password: env.DB_PASSWORD,
  });
  await adminConn.query(`DROP DATABASE IF EXISTS \`${env.DB_NAME}\`;`);
  await adminConn.end();

  // Fresh DB migrate & seed in test database
  await migrate();
  await seed();

  const app = createApp();
  const server = http.createServer(app);

  await new Promise((resolve) => server.listen(0, resolve));
  const port = server.address().port;
  console.log(`Test server running on port ${port}`);

  let accessToken = '';
  let refreshToken = '';
  let createdTaskId = null;

  try {
    // 1. Health Check
    console.log('1. Testing Health Check & Swagger UI...');
    const health = await request(server, { path: '/api/health' });
    assert.strictEqual(health.status, 200);
    assert.strictEqual(health.body.status, 'healthy');

    const swaggerDocs = await request(server, { path: '/api/docs/' });
    assert.ok(swaggerDocs.status === 200 || swaggerDocs.status === 301 || swaggerDocs.status === 302);
    console.log('   ✅ Health check & Swagger docs (/api/docs) passed.');

    // 2. Auth: Signup
    console.log('2. Testing User Signup...');
    const signupRes = await request(
      server,
      { path: '/api/auth/signup', method: 'POST' },
      {
        name: 'Test Automation User',
        email: 'testuser@example.com',
        password: 'Password123!',
      }
    );
    assert.strictEqual(signupRes.status, 201);
    assert.strictEqual(signupRes.body.success, true);
    assert.ok(signupRes.body.data.user);
    assert.ok(signupRes.body.data.accessToken);
    assert.ok(signupRes.body.data.refreshToken);
    console.log('   ✅ Signup passed.');

    // 3. Auth: Signup Duplicate Email (Negative Test)
    console.log('3. Testing Duplicate Email Signup...');
    const dupRes = await request(
      server,
      { path: '/api/auth/signup', method: 'POST' },
      {
        name: 'Duplicate User',
        email: 'testuser@example.com',
        password: 'Password123!',
      }
    );
    assert.strictEqual(dupRes.status, 409);
    console.log('   ✅ Duplicate signup correctly rejected (409).');

    // 4. Auth: Login
    console.log('4. Testing User Login...');
    const loginRes = await request(
      server,
      { path: '/api/auth/login', method: 'POST' },
      {
        email: 'testuser@example.com',
        password: 'Password123!',
      }
    );
    assert.strictEqual(loginRes.status, 200);
    assert.strictEqual(loginRes.body.success, true);
    accessToken = loginRes.body.data.accessToken;
    refreshToken = loginRes.body.data.refreshToken;
    assert.ok(accessToken);
    assert.ok(refreshToken);
    console.log('   ✅ Login passed.');

    // 5. Auth: Token Refresh & Rotation
    console.log('5. Testing Token Refresh...');
    const refreshRes = await request(
      server,
      { path: '/api/auth/refresh', method: 'POST' },
      { refreshToken }
    );
    assert.strictEqual(refreshRes.status, 200);
    assert.strictEqual(refreshRes.body.success, true);
    assert.ok(refreshRes.body.data.accessToken);
    assert.ok(refreshRes.body.data.refreshToken);
    assert.notStrictEqual(refreshRes.body.data.refreshToken, refreshToken);
    accessToken = refreshRes.body.data.accessToken;
    refreshToken = refreshRes.body.data.refreshToken;
    console.log('   ✅ Token refresh and rotation passed.');

    // 6. Users: Get Team Members
    console.log('6. Testing Get Team Members API...');
    const usersRes = await request(server, {
      path: '/api/users',
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    assert.strictEqual(usersRes.status, 200);
    assert.strictEqual(usersRes.body.success, true);
    assert.ok(Array.isArray(usersRes.body.data));
    assert.ok(usersRes.body.data.length >= 4);
    assert.strictEqual(usersRes.body.data[0].password_hash, undefined);
    console.log(`   ✅ Team members retrieved (${usersRes.body.data.length} users).`);

    // 7. Tasks: Validation Failures
    console.log('7. Testing Create Task Validations (Negative tests)...');

    // 7a. Empty Title
    const emptyTitleRes = await request(
      server,
      { path: '/api/tasks', method: 'POST', headers: { Authorization: `Bearer ${accessToken}` } },
      { title: '   ', dueDate: '2026-09-15' }
    );
    assert.strictEqual(emptyTitleRes.status, 422);
    assert.strictEqual(emptyTitleRes.body.errors.title, 'Task title is required');

    // 7a-2. Title < 3 chars
    const shortTitleRes = await request(
      server,
      { path: '/api/tasks', method: 'POST', headers: { Authorization: `Bearer ${accessToken}` } },
      { title: 'AB', dueDate: '2026-09-15' }
    );
    assert.strictEqual(shortTitleRes.status, 422);
    assert.strictEqual(shortTitleRes.body.errors.title, 'Task title must be at least 3 characters');

    // 7b. Title > 100 chars
    const longTitleRes = await request(
      server,
      { path: '/api/tasks', method: 'POST', headers: { Authorization: `Bearer ${accessToken}` } },
      { title: 'A'.repeat(101), dueDate: '2026-09-15' }
    );
    assert.strictEqual(longTitleRes.status, 422);
    assert.strictEqual(longTitleRes.body.errors.title, 'Task title cannot exceed 100 characters');

    // 7c. Description > 1000 chars
    const longDescRes = await request(
      server,
      { path: '/api/tasks', method: 'POST', headers: { Authorization: `Bearer ${accessToken}` } },
      { title: 'Valid Title', description: 'D'.repeat(1001), dueDate: '2026-09-15' }
    );
    assert.strictEqual(longDescRes.status, 422);
    assert.strictEqual(longDescRes.body.errors.description, 'Description cannot exceed 1000 characters');

    // 7d. Invalid Status
    const invalidStatusRes = await request(
      server,
      { path: '/api/tasks', method: 'POST', headers: { Authorization: `Bearer ${accessToken}` } },
      { title: 'Valid Title', status: 'INVALID_STATUS', dueDate: '2026-09-15' }
    );
    assert.strictEqual(invalidStatusRes.status, 422);
    assert.strictEqual(invalidStatusRes.body.errors.status, 'Invalid task status');

    // 7e. Past Due Date
    const pastDueDateRes = await request(
      server,
      { path: '/api/tasks', method: 'POST', headers: { Authorization: `Bearer ${accessToken}` } },
      { title: 'Valid Title', dueDate: '2020-01-01' }
    );
    assert.strictEqual(pastDueDateRes.status, 422);
    assert.strictEqual(pastDueDateRes.body.errors.dueDate, 'Due date cannot be in the past');

    // 7f. Non-existent Assignee
    const invalidAssigneeRes = await request(
      server,
      { path: '/api/tasks', method: 'POST', headers: { Authorization: `Bearer ${accessToken}` } },
      { title: 'Valid Title', assigneeId: 999999, dueDate: '2026-09-15' }
    );
    assert.strictEqual(invalidAssigneeRes.status, 400);
    assert.strictEqual(invalidAssigneeRes.body.message, 'Selected assignee is not available');

    console.log('   ✅ All negative validation tests rejected as expected.');

    // 8. Tasks: Create Task (Positive test with today's date and unassigned)
    console.log('8. Testing Create Task (Valid inputs)...');
    const now = new Date();
    const todayStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
    const createTaskRes = await request(
      server,
      {
        path: '/api/tasks',
        method: 'POST',
        headers: { Authorization: `Bearer ${accessToken}` },
      },
      {
        title: 'New Automated Test Task',
        description: 'Testing task creation with full validations',
        status: 'TODO',
        assigneeId: usersRes.body.data[1].id,
        dueDate: todayStr,
      }
    );
    assert.strictEqual(createTaskRes.status, 201);
    assert.strictEqual(createTaskRes.body.success, true);
    assert.strictEqual(createTaskRes.body.data.title, 'New Automated Test Task');
    assert.strictEqual(createTaskRes.body.data.status, 'TODO');
    assert.ok(createTaskRes.body.data.assignee);
    assert.strictEqual(createTaskRes.body.data.assignee.id, usersRes.body.data[1].id);
    createdTaskId = createTaskRes.body.data.id;
    console.log(`   ✅ Task created (ID: ${createdTaskId}).`);

    // 9. Tasks: Get Tasks with Filter & Search & Pagination
    console.log('9. Testing Get Tasks with Search & Filter...');
    const getTasksRes = await request(server, {
      path: '/api/tasks?search=Automated&status=TODO&page=1&limit=10',
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    assert.strictEqual(getTasksRes.status, 200);
    assert.strictEqual(getTasksRes.body.success, true);
    assert.ok(Array.isArray(getTasksRes.body.data));
    assert.ok(getTasksRes.body.data.length >= 1);
    assert.strictEqual(getTasksRes.body.pagination.page, 1);
    console.log('   ✅ Get tasks with filter/search passed.');

    // 10. Tasks: Get Task By ID
    console.log('10. Testing Get Task By ID...');
    const getTaskByIdRes = await request(server, {
      path: `/api/tasks/${createdTaskId}`,
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    assert.strictEqual(getTaskByIdRes.status, 200);
    assert.strictEqual(getTaskByIdRes.body.data.id, createdTaskId);
    console.log('   ✅ Get task by ID passed.');

    // 11. Tasks: Update Task
    console.log('11. Testing Update Task...');
    const updateTaskRes = await request(
      server,
      {
        path: `/api/tasks/${createdTaskId}`,
        method: 'PUT',
        headers: { Authorization: `Bearer ${accessToken}` },
      },
      {
        title: 'Updated Test Task Title',
        status: 'DONE',
      }
    );
    assert.strictEqual(updateTaskRes.status, 200);
    assert.strictEqual(updateTaskRes.body.data.title, 'Updated Test Task Title');
    assert.strictEqual(updateTaskRes.body.data.status, 'DONE');
    console.log('   ✅ Task update passed.');

    // 12. Tasks: Delete Task
    console.log('12. Testing Delete Task...');
    const deleteTaskRes = await request(server, {
      path: `/api/tasks/${createdTaskId}`,
      method: 'DELETE',
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    assert.strictEqual(deleteTaskRes.status, 200);
    assert.strictEqual(deleteTaskRes.body.success, true);
    console.log('   ✅ Task deleted successfully.');

    // 13. Auth Guard: Request without token (Negative test)
    console.log('13. Testing Unauthorized access check...');
    const unauthorizedRes = await request(server, { path: '/api/tasks' });
    assert.strictEqual(unauthorizedRes.status, 401);
    console.log('   ✅ Unauthorized request blocked correctly (401).');

    // 14. Auth: Logout
    console.log('14. Testing User Logout...');
    const logoutRes = await request(
      server,
      { path: '/api/auth/logout', method: 'POST' },
      { refreshToken }
    );
    assert.strictEqual(logoutRes.status, 200);
    assert.strictEqual(logoutRes.body.success, true);
    console.log('   ✅ Logout passed.');

    console.log('\n🎉 ALL BACKEND INTEGRATION & VALIDATION TESTS PASSED PERFECTLY!\n');
  } finally {
    server.close();
    await disconnectDatabase();
  }
}

runTests().catch((err) => {
  console.error('❌ Test failed:', err);
  process.exit(1);
});
