import { db } from "../config/firebase.js";

const eventsCollection = db.collection('events');
const eventCalendarCollection = db.collection('event_calendar');

// GET /api/event?date=2026-03-15
export const getEventsByDate = async (date: string, familyId: string) => {
    const snapshot = await eventsCollection
        .where('date', '==', date)
        .where('familyId', '==', familyId)
        .get();

    if (snapshot.empty) return [];

    return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
    }));
};

// GET /api/event-calendar?month=03&year=2026
export const getEventCalendarByMonth = async (month: string, year: string) => {
    const paddedMonth = month.padStart(2, '0');
    const prefix = `${year}-${paddedMonth}`;

    const snapshot = await eventCalendarCollection
        .where('date', '>=', `${prefix}-01`)
        .where('date', '<=', `${prefix}-31`)
        .get();

    if (snapshot.empty) return [];

    return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
    }));
};