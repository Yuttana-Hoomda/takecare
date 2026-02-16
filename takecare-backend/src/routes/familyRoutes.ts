import { Router } from 'express';
import { addCaregiverToFamily, createFamily } from '../controllers/familyController.js';

const router = Router();

// GET /api/users/profile - Fetches the logged-in user's data
router.patch('/family/:familyId', addCaregiverToFamily );

// POST /api/users/profile - Saves user data (role, conditions, etc.) after they sign up
router.post('/family', createFamily);

export default router;