import { Router } from 'express';
import { getDailySummaryHandler, getRecentEventsHandler } from '../controllers/caregiverHomeController.js';

const router = Router();

// GET /api/home/summary?familyId=xxx&date=2026-03-28
router.get('/home/summary', getDailySummaryHandler);

// GET /api/home/recent-events?familyId=xxx&date=2026-03-28
router.get('/home/recent-events', getRecentEventsHandler);

export default router;
