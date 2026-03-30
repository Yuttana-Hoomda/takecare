import type { Request, Response } from 'express';
import { getDailySummary, getRecentEvents } from '../services/caregiverHomeService.js';

// GET /api/home/summary?familyId=xxx&date=2026-03-28
export const getDailySummaryHandler = async (req: Request, res: Response): Promise<void> => {
  try {
    const { familyId, date } = req.query;

    if (!familyId || typeof familyId !== 'string') {
      res.status(400).json({ error: 'familyId is required' });
      return;
    }

    // default to today (Bangkok time) if date not provided
    const targetDate = typeof date === 'string'
      ? date
      : new Date().toLocaleDateString('en-CA', { timeZone: 'Asia/Bangkok' });

    const summary = await getDailySummary(familyId, targetDate);
    res.status(200).json(summary);
  } catch (error) {
    console.error('getDailySummary error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// GET /api/home/recent-events?familyId=xxx&date=2026-03-28
export const getRecentEventsHandler = async (req: Request, res: Response): Promise<void> => {
  try {
    const { familyId, date } = req.query;

    if (!familyId || typeof familyId !== 'string') {
      res.status(400).json({ error: 'familyId is required' });
      return;
    }

    const targetDate = typeof date === 'string'
      ? date
      : new Date().toLocaleDateString('en-CA', { timeZone: 'Asia/Bangkok' });

    const events = await getRecentEvents(familyId, targetDate);
    res.status(200).json(events);
  } catch (error) {
    console.error('getRecentEvents error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
