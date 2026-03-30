import { Router } from 'express';
import { submitTaskController, getSubmissionsByFamily } from '../controllers/taskSubmissionController.js';

const router = Router();

// POST /api/task-submissions
router.post('/task-submissions', submitTaskController);

// GET /api/task-submissions/family/:familyId?date=YYYY-MM-DD
router.get('/task-submissions/family/:familyId', getSubmissionsByFamily);

export default router;
