import { Router } from 'express';
import { createFamily, linkFamily } from '../controllers/familyController.js';
import { verifyToken } from '../middlewares/middleware.js';

const router = Router();

// POST /api/families          - สร้าง family ด้วย elderId + caregiverId (admin use)
router.post('/families', verifyToken, createFamily);

// ✅ ใหม่: POST /api/families/link  body: { elderUid }
// caregiver เรียกตัวนี้หลังกรอกเบอร์ elder และยืนยันแล้ว
router.post('/families/link', verifyToken, linkFamily);

export default router;
