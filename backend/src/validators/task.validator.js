const { z } = require('zod');
const { ValidTaskStatuses } = require('../config/constants');

// Helper to get today's date in YYYY-MM-DD in local time
function getTodayDateString() {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

const createTaskSchema = z.object({
  title: z
    .string({
      errorMap: (issue) => {
        if (issue.code === 'invalid_type' && issue.received === 'undefined') {
          return { message: 'Task title is required' };
        }
        return { message: 'Task title is required' };
      },
    })
    .trim()
    .min(1, 'Task title is required')
    .min(3, 'Task title must be at least 3 characters')
    .max(100, 'Task title cannot exceed 100 characters'),
  description: z
    .string()
    .trim()
    .max(1000, 'Description cannot exceed 1000 characters')
    .optional()
    .nullable(),
  status: z
    .enum(ValidTaskStatuses, {
      errorMap: (issue) => {
        if (issue.code === 'invalid_type' && issue.received === 'undefined') {
          return { message: 'Status is required' };
        }
        return { message: 'Invalid task status' };
      },
    })
    .default('TODO'),
  assigneeId: z
    .union([z.coerce.number().int().positive(), z.null()])
    .optional()
    .nullable(),
  dueDate: z
    .string({
      errorMap: (issue) => {
        if (issue.code === 'invalid_type' && issue.received === 'undefined') {
          return { message: 'Due date is required' };
        }
        return { message: 'Due date is required' };
      },
    })
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Due date must be in YYYY-MM-DD format')
    .refine(
      (val) => {
        const today = getTodayDateString();
        return val >= today;
      },
      {
        message: 'Due date cannot be in the past',
      }
    ),
});

const updateTaskSchema = z.object({
  title: z
    .string()
    .trim()
    .min(1, 'Task title is required')
    .min(3, 'Task title must be at least 3 characters')
    .max(100, 'Task title cannot exceed 100 characters')
    .optional(),
  description: z
    .string()
    .trim()
    .max(1000, 'Description cannot exceed 1000 characters')
    .optional()
    .nullable(),
  status: z
    .enum(ValidTaskStatuses, {
      errorMap: () => ({ message: 'Invalid task status' }),
    })
    .optional(),
  assigneeId: z
    .union([z.coerce.number().int().positive(), z.null()])
    .optional()
    .nullable(),
  dueDate: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Due date must be in YYYY-MM-DD format')
    .refine(
      (val) => {
        if (!val) return true;
        const today = getTodayDateString();
        return val >= today;
      },
      {
        message: 'Due date cannot be in the past',
      }
    )
    .optional(),
});

const getTasksQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  status: z.enum(ValidTaskStatuses).optional(),
  search: z.string().trim().optional(),
  sortBy: z.enum(['dueDate', 'createdAt', 'title', 'status']).default('dueDate'),
  sortOrder: z.enum(['asc', 'desc', 'ASC', 'DESC']).default('asc'),
});

module.exports = {
  createTaskSchema,
  updateTaskSchema,
  getTasksQuerySchema,
};
