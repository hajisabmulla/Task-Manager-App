# ⚙️ Task Manager — Backend API Service

A modular, production-grade **Node.js + Express.js + MySQL** REST API backend built in pure JavaScript (CommonJS) with layered architecture, JWT authentication, refresh token rotation, Zod validation, and automated integration tests.

---

## 🏛️ Architecture & Layered Structure

The backend strictly follows a layered architecture separating routing, validation, business logic, and database queries:

```
backend/
├── database/
│   ├── init.sql              # SQL Schema definition with indexes & constraints
│   ├── migrate.js            # Automated schema migration runner
│   └── seed.js               # Seed script with 4 team members and 8 tasks
├── src/
│   ├── config/
│   │   ├── constants.js      # App constants, status enums, salt rounds
│   │   ├── database.js       # MySQL connection pool (with dateStrings: true)
│   │   └── env.js            # Environment variable validation & fallback
│   ├── controllers/
│   │   ├── auth.controller.js# Authentication HTTP handlers
│   │   ├── task.controller.js# Task CRUD HTTP handlers
│   │   └── user.controller.js# Team members HTTP handlers
│   ├── middleware/
│   │   ├── auth.middleware.js# Bearer JWT access token verification
│   │   ├── error.middleware.js# Centralized error handler & status mapping
│   │   └── validate.middleware.js # Zod schema validation middleware
│   ├── repositories/
│   │   ├── task.repository.js# Parameterized MySQL queries for tasks
│   │   ├── token.repository.js# Refresh token CRUD & revocation
│   │   └── user.repository.js# User lookup, signup, and directory queries
│   ├── routes/
│   │   ├── auth.routes.js    # /api/auth routes
│   │   ├── task.routes.js    # /api/tasks routes
│   │   ├── user.routes.js    # /api/users routes
│   │   └── index.js          # Main API router mounting
│   ├── services/
│   │   ├── auth.service.js   # Password hashing, JWT generation, rotation
│   │   ├── task.service.js   # Task business logic & assignee validation
│   │   └── user.service.js   # User business logic
│   ├── utils/
│   │   ├── app-error.js      # Custom error class with HTTP status codes
│   │   └── logger.js         # Standardized formatted logger
│   ├── validators/
│   │   ├── auth.validator.js # Zod schemas for signup & login
│   │   └── task.validator.js # Zod schemas for task CRUD & queries
│   ├── app.js                # Express app initialization & security middlewares
│   └── server.js             # HTTP server bootstrap & graceful shutdown
├── tests/
│   └── api.test.js           # Full E2E integration test suite
├── .env.example              # Sample environment configuration
├── package.json
└── README.md
```

---

## 🌐 Interactive Swagger API Documentation
An interactive OpenAPI 3.0 Swagger UI is built-in and accessible at:
* **Swagger UI URL**: `http://localhost:3000/api/docs`
* Allows testing endpoints, reviewing JSON schemas, and executing authenticated requests directly in the browser.
* **Postman Collection**: Exportable file ready for import located at [`backend/postman_collection.json`](file:///d:/assignment/backend/postman_collection.json).

---

## 🗄️ Database Design & Schema

### Tables & Relationships
1. **`users`**:
   * `id` INT AUTO_INCREMENT PRIMARY KEY
   * `name` VARCHAR(100) NOT NULL
   * `email` VARCHAR(255) NOT NULL UNIQUE (Indexed)
   * `password_hash` VARCHAR(255) NOT NULL
   * `created_at` / `updated_at` TIMESTAMP
2. **`refresh_tokens`**:
   * `id` INT AUTO_INCREMENT PRIMARY KEY
   * `user_id` INT NOT NULL (FK ➔ `users.id` ON DELETE CASCADE)
   * `token_hash` VARCHAR(255) NOT NULL UNIQUE (Indexed)
   * `expires_at` TIMESTAMP NOT NULL
   * `revoked_at` TIMESTAMP NULL DEFAULT NULL
3. **`tasks`**:
   * `id` INT AUTO_INCREMENT PRIMARY KEY
   * `title` VARCHAR(255) NOT NULL
   * `description` TEXT NULL
   * `status` ENUM('TODO', 'IN_PROGRESS', 'DONE') NOT NULL DEFAULT 'TODO' (Indexed)
   * `assignee_id` INT NULL (FK ➔ `users.id` ON DELETE SET NULL, Indexed)
   * `created_by_id` INT NOT NULL (FK ➔ `users.id` ON DELETE CASCADE, Indexed)
   * `due_date` DATE NOT NULL (Indexed)
   * `created_at` / `updated_at` TIMESTAMP

---

## 🔐 Authentication & Token Lifecycle

* **Access Token**: Short-lived (15 minutes), signed with `JWT_ACCESS_SECRET`.
* **Refresh Token**: Cryptographically random 40-byte hex token, hashed with SHA-256 and stored in MySQL with a 7-day expiration.
* **Token Rotation**: Each refresh request consumes the old refresh token, marks it revoked, and issues a brand-new refresh token.
* **Revocation & Logout**: Calling `/api/auth/logout` immediately invalidates the active refresh token in the database.

---

## 📡 REST API Documentation

### 1. Authentication
* **`POST /api/auth/signup`** — Register a new account
  * Request: `{ "name": "John Doe", "email": "john@example.com", "password": "Password123!" }`
  * Response: `201 Created` with user info and token pair.
* **`POST /api/auth/login`** — Sign in
  * Request: `{ "email": "john@example.com", "password": "Password123!" }`
  * Response: `200 OK` with user info and token pair.
* **`POST /api/auth/refresh`** — Exchange refresh token for new access token
  * Request: `{ "refreshToken": "<raw_refresh_token>" }`
  * Response: `200 OK` with rotated tokens.
* **`POST /api/auth/logout`** — Invalidate active session
  * Request: `{ "refreshToken": "<raw_refresh_token>" }`
  * Response: `200 OK`

### 2. Team Members
* **`GET /api/users`** — Get all registered team members
  * Header: `Authorization: Bearer <access_token>`
  * Response: `200 OK` with array of users.

### 3. Tasks
* **`GET /api/tasks`** — Paginated tasks with status filtering, title search, and sorting
  * Query params: `page`, `limit`, `status` (`TODO|IN_PROGRESS|DONE`), `search`, `sortBy`, `sortOrder`
  * Response: `200 OK` with `{ tasks: [...], pagination: { page, limit, total, totalPages } }`
* **`POST /api/tasks`** — Create task
  * Request: `{ "title": "Fix bug #12", "description": "Details", "status": "TODO", "assigneeId": 1, "dueDate": "2026-09-05" }`
  * Response: `201 Created`
* **`GET /api/tasks/:id`** — Get task by ID
* **`PUT /api/tasks/:id`** — Update task details or status
* **`DELETE /api/tasks/:id`** — Delete task

---

## 🔑 Demo Credentials (from Seed Data)

All demo accounts use the password: `password123`

| Name | Email |
|---|---|
| **Alex Johnson** | `alex@example.com` |
| **Sarah Connor** | `sarah@example.com` |
| **David Smith** | `david@example.com` |
| **Emily Davis** | `emily@example.com` |

---

## 🚀 Setup & Execution

### 1. Prerequisites
* Node.js v18+ or v20+ LTS
* MySQL Server running on port 3306

### 2. Install Dependencies
```bash
npm install
```

### 3. Environment Configuration
Create a `.env` file (copied from `.env.example`):
```env
PORT=3000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=task_manager_db
JWT_ACCESS_SECRET=your_super_secret_access_key_12345
JWT_REFRESH_SECRET=your_super_secret_refresh_key_67890
JWT_ACCESS_EXPIRATION=15m
JWT_REFRESH_EXPIRATION_DAYS=7
```

### 4. Database Migration & Seeding
```bash
# Run database schema migration
npm run db:migrate

# Seed demo users and initial tasks
npm run db:seed
```

### 5. Start Backend Server
```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

### 6. Run Integration Tests
```bash
npm test
```
*Executes all 14 end-to-end integration and negative validation test suites against a live test server.*
