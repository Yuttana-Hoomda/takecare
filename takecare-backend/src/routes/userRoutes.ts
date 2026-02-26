import { Router } from 'express';
import { getProfile, createProfile, searchUserByPhone } from '../controllers/userController.js';
import { verifyToken } from '../middlewares/middleware.js';

const router = Router();

// GET  /api/users/profile          - ดึงข้อมูล user ที่ login อยู่
router.get('/profile', verifyToken, getProfile);

// POST /api/users/profile          - สร้าง profile หลัง sign up
router.post('/profile', verifyToken, createProfile);

// ✅ ใหม่ GET /api/users/search?phone=0812345678  - ค้นหา user จากเบอร์โทร
router.get('/search', verifyToken, searchUserByPhone);

export default router;
