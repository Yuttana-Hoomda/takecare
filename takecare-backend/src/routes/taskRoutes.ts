import { Router } from 'express';
import { createTask, deleteTask, getTasksForFamily, updateTask } from '../controllers/taskController.js';

const router = Router();

router.post('/tasks', createTask);
router.get('/tasks/family/:familyId', getTasksForFamily);
router.patch('/tasks/:taskId', updateTask);
router.delete('/tasks/:taskId', deleteTask);

export default router;