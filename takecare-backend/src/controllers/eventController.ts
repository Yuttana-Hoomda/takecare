import type { Request, Response } from 'express';
import { getEventsByDate, getEventCalendarByMonth } from '../services/eventService.js';

export const getEventsByDateHandler = async (req: Request, res: Response) => {
    try {
        const { date, familyId } = req.query;

        if (!date || typeof date !== 'string') {
            return res.status(400).json({ error: 'date query param is required (e.g. ?date=2026-03-15)' });
        }
        if (!familyId || typeof familyId !== 'string') {
            return res.status(400).json({ error: 'familyId query param is required' });
        }

        const events = await getEventsByDate(date, familyId);
        return res.status(200).json(events);
    } catch (error) {
        console.error('getEventsByDate error:', error);
        return res.status(500).json({ error: 'Internal server error' });
    }
};

export const getEventCalendarHandler = async (req: Request, res: Response) => {
    try {
        // ดึง familyId มาจาก query parameters
        const { month, year, familyId } = req.query;

        if (!month || !year || !familyId) {
            return res.status(400).json({ 
                error: 'month, year, and familyId query params are required' 
            });
        }

        // ส่ง familyId เข้าไป
        const data = await getEventCalendarByMonth(
            month as string,
            year as string,
            familyId as string
        );
        
        return res.status(200).json(data);
    } catch (error) {
        console.error('getEventCalendar error:', error);
        return res.status(500).json({ error: 'Internal server error' });
    }
};