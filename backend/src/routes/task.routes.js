const { Router } = require('express');
const taskController = require('../controllers/task.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { validate } = require('../middleware/validate.middleware');
const {
  createTaskSchema,
  updateTaskSchema,
  getTasksQuerySchema,
} = require('../validators/task.validator');

const router = Router();

router.use(authenticate);

router.post('/', validate(createTaskSchema), taskController.create);
router.get('/', validate(getTasksQuerySchema, 'query'), taskController.getAll);
router.get('/:id', taskController.getById);
router.put('/:id', validate(updateTaskSchema), taskController.update);
router.delete('/:id', taskController.delete);

module.exports = router;
