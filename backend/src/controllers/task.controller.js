const taskService = require('../services/task.service');
const { success } = require('../utils/api-response');
const { asyncHandler } = require('../utils/async-handler');

class TaskController {
  create = asyncHandler(async (req, res) => {
    const createdById = req.user.id;
    const task = await taskService.createTask(req.body, createdById);
    res.status(201).json(success(task, 'Task created successfully'));
  });

  getAll = asyncHandler(async (req, res) => {
    const result = await taskService.getTasks(req.query);
    res.status(200).json(success(result.tasks, 'Tasks retrieved successfully', result.pagination));
  });

  getById = asyncHandler(async (req, res) => {
    const taskId = Number(req.params.id);
    const task = await taskService.getTaskById(taskId);
    res.status(200).json(success(task, 'Task details retrieved successfully'));
  });

  update = asyncHandler(async (req, res) => {
    const taskId = Number(req.params.id);
    const task = await taskService.updateTask(taskId, req.body);
    res.status(200).json(success(task, 'Task updated successfully'));
  });

  delete = asyncHandler(async (req, res) => {
    const taskId = Number(req.params.id);
    await taskService.deleteTask(taskId);
    res.status(200).json(success(null, 'Task deleted successfully'));
  });
}

module.exports = new TaskController();
