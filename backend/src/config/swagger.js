const swaggerUi = require('swagger-ui-express');

const swaggerDocument = {
  openapi: '3.0.0',
  info: {
    title: 'Task Manager REST API',
    version: '1.0.0',
    description: 'RESTful API for the Task Manager Application built with Node.js, Express, and MySQL.',
    contact: {
      name: 'API Support',
    },
  },
  servers: [
    {
      url: '/api',
      description: 'API Base Server',
    },
  ],
  components: {
    securitySchemes: {
      BearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Enter your 15-minute JWT Access Token',
      },
    },
    schemas: {
      ApiResponse: {
        type: 'object',
        properties: {
          success: { type: 'boolean' },
          message: { type: 'string' },
          data: { type: 'object' },
        },
      },
      User: {
        type: 'object',
        properties: {
          id: { type: 'integer', example: 1 },
          name: { type: 'string', example: 'Alex Johnson' },
          email: { type: 'string', example: 'alex@example.com' },
          createdAt: { type: 'string', format: 'date-time' },
        },
      },
      Task: {
        type: 'object',
        properties: {
          id: { type: 'integer', example: 1 },
          title: { type: 'string', example: 'Design Authentication Architecture' },
          description: { type: 'string', example: 'Set up JWT and refresh token rotation.' },
          status: { type: 'string', enum: ['TODO', 'IN_PROGRESS', 'DONE'], example: 'TODO' },
          dueDate: { type: 'string', format: 'date', example: '2026-09-15' },
          assignee: { $ref: '#/components/schemas/User' },
          createdBy: { $ref: '#/components/schemas/User' },
          createdAt: { type: 'string', format: 'date-time' },
          updatedAt: { type: 'string', format: 'date-time' },
        },
      },
      ValidationError: {
        type: 'object',
        properties: {
          success: { type: 'boolean', example: false },
          message: { type: 'string', example: 'Validation failed' },
          errors: {
            type: 'object',
            additionalProperties: { type: 'string' },
            example: { title: 'Task title is required' },
          },
        },
      },
    },
  },
  paths: {
    '/health': {
      get: {
        summary: 'Health Check',
        tags: ['System'],
        responses: {
          200: {
            description: 'Server is healthy',
          },
        },
      },
    },
    '/auth/signup': {
      post: {
        summary: 'User Signup',
        tags: ['Authentication'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['name', 'email', 'password'],
                properties: {
                  name: { type: 'string', example: 'Alex Johnson' },
                  email: { type: 'string', example: 'alex@example.com' },
                  password: { type: 'string', example: 'Password123!' },
                },
              },
            },
          },
        },
        responses: {
          201: { description: 'User created successfully' },
          409: { description: 'Email already in use' },
          422: { description: 'Validation error' },
        },
      },
    },
    '/auth/login': {
      post: {
        summary: 'User Login',
        tags: ['Authentication'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['email', 'password'],
                properties: {
                  email: { type: 'string', example: 'alex@example.com' },
                  password: { type: 'string', example: 'password123' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'Login successful' },
          401: { description: 'Invalid credentials' },
        },
      },
    },
    '/auth/refresh': {
      post: {
        summary: 'Refresh Access Token (Token Rotation)',
        tags: ['Authentication'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['refreshToken'],
                properties: {
                  refreshToken: { type: 'string' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'Token refreshed successfully' },
          401: { description: 'Invalid or revoked refresh token' },
        },
      },
    },
    '/auth/logout': {
      post: {
        summary: 'User Logout (Revoke Token)',
        tags: ['Authentication'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['refreshToken'],
                properties: {
                  refreshToken: { type: 'string' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'Logged out successfully' },
        },
      },
    },
    '/users': {
      get: {
        summary: 'Get Team Members',
        tags: ['Team'],
        security: [{ BearerAuth: [] }],
        responses: {
          200: {
            description: 'List of all team members',
          },
          401: { description: 'Unauthorized' },
        },
      },
    },
    '/tasks': {
      get: {
        summary: 'List Tasks (Paginated, Search, Filter & Sort)',
        tags: ['Tasks'],
        security: [{ BearerAuth: [] }],
        parameters: [
          { name: 'page', in: 'query', schema: { type: 'integer', default: 1 } },
          { name: 'limit', in: 'query', schema: { type: 'integer', default: 10 } },
          { name: 'status', in: 'query', schema: { type: 'string', enum: ['TODO', 'IN_PROGRESS', 'DONE'] } },
          { name: 'search', in: 'query', schema: { type: 'string' } },
          { name: 'sortBy', in: 'query', schema: { type: 'string', enum: ['dueDate', 'createdAt', 'title', 'status'], default: 'dueDate' } },
          { name: 'sortOrder', in: 'query', schema: { type: 'string', enum: ['asc', 'desc'], default: 'asc' } },
        ],
        responses: {
          200: { description: 'Paginated task list' },
          401: { description: 'Unauthorized' },
        },
      },
      post: {
        summary: 'Create Task',
        tags: ['Tasks'],
        security: [{ BearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['title', 'status', 'dueDate'],
                properties: {
                  title: { type: 'string', example: 'Implement feature X' },
                  description: { type: 'string', example: 'Details of feature X' },
                  status: { type: 'string', enum: ['TODO', 'IN_PROGRESS', 'DONE'], default: 'TODO' },
                  assigneeId: { type: 'integer', nullable: true, example: 1 },
                  dueDate: { type: 'string', format: 'date', example: '2026-09-15' },
                },
              },
            },
          },
        },
        responses: {
          201: { description: 'Task created successfully' },
          422: { description: 'Validation failed' },
        },
      },
    },
    '/tasks/{id}': {
      get: {
        summary: 'Get Task by ID',
        tags: ['Tasks'],
        security: [{ BearerAuth: [] }],
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
        responses: {
          200: { description: 'Task details' },
          404: { description: 'Task not found' },
        },
      },
      put: {
        summary: 'Update Task',
        tags: ['Tasks'],
        security: [{ BearerAuth: [] }],
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  title: { type: 'string' },
                  description: { type: 'string' },
                  status: { type: 'string', enum: ['TODO', 'IN_PROGRESS', 'DONE'] },
                  assigneeId: { type: 'integer', nullable: true },
                  dueDate: { type: 'string', format: 'date' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'Task updated successfully' },
          404: { description: 'Task not found' },
          422: { description: 'Validation failed' },
        },
      },
      delete: {
        summary: 'Delete Task',
        tags: ['Tasks'],
        security: [{ BearerAuth: [] }],
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
        responses: {
          200: { description: 'Task deleted successfully' },
          404: { description: 'Task not found' },
        },
      },
    },
  },
};

function setupSwagger(app) {
  app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
}

module.exports = { setupSwagger, swaggerDocument };
