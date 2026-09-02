const taskRepository = require('../repositories/task.repository');
const userRepository = require('../repositories/user.repository');
const { AppError } = require('../utils/app-error');

class TaskService {
  async createTask(data, createdById) {
    if (data.assigneeId) {
      const assignee = await userRepository.findById(data.assigneeId);
      if (!assignee) {
        throw AppError.badRequest('Selected assignee is not available', 'ASSIGNEE_NOT_FOUND');
      }
    }

    return taskRepository.create({
      title: data.title,
      description: data.description,
      status: data.status || 'TODO',
      assigneeId: data.assigneeId,
      createdById,
      dueDate: data.dueDate,
    });
  }

  async getTasks(queryParams) {
    return taskRepository.findAll(queryParams);
  }

  async getTaskById(id) {
    const task = await taskRepository.findById(id);
    if (!task) {
      throw AppError.notFound('Task not found', 'TASK_NOT_FOUND');
    }
    return task;
  }

  async updateTask(id, updateData) {
    const existing = await taskRepository.findById(id);
    if (!existing) {
      throw AppError.notFound('Task not found', 'TASK_NOT_FOUND');
    }

    if (updateData.assigneeId !== undefined && updateData.assigneeId !== null) {
      const assignee = await userRepository.findById(updateData.assigneeId);
      if (!assignee) {
        throw AppError.badRequest('Selected assignee is not available', 'ASSIGNEE_NOT_FOUND');
      }
    }

    return taskRepository.update(id, updateData);
  }

  async deleteTask(id) {
    const existing = await taskRepository.findById(id);
    if (!existing) {
      throw AppError.notFound('Task not found', 'TASK_NOT_FOUND');
    }
    return taskRepository.delete(id);
  }
}

module.exports = new TaskService();
