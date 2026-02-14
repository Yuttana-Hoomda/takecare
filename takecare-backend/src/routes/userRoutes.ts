import { Router } from 'express';
import { getProfile, createProfile } from '../controllers/userController.js';
import { verifyToken } from '../middlewares/middleware.js';

const router = Router();

// GET /api/users/profile - Fetches the logged-in user's data
router.get('/profile', verifyToken, getProfile);

// POST /api/users/profile - Saves user data (role, conditions, etc.) after they sign up
router.post('/profile', verifyToken, createProfile);

export default router;