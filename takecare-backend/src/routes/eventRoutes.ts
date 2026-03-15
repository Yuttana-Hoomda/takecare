import { Router } from 'express';
import { getEventsByDateHandler, getEventCalendarHandler } from '../controllers/eventController.js';

const router = Router();

// GET /api/event?date=2026-03-15
router.get('/event', getEventsByDateHandler);

// GET /api/event-calendar?month=03&year=2026
router.get('/event-calendar', getEventCalendarHandler);

export default router;