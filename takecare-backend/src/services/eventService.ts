import { db } from "../config/firebase.js";

const eventsCollection = db.collection('events');

// GET /api/event?date=2026-03-15&familyId=xxx
export const getEventsByDate = async (date: string, familyId: string) => {
    const snapshot = await eventsCollection
        .where('familyId', '==', familyId)
        .get();

    if (snapshot.empty) return [];

    return snapshot.docs
        .map(doc => ({ id: doc.id, ...doc.data() }))
        .filter(data => data.date === date);
};

// GET /api/event-calendar?month=03&year=2026&familyId=xxx
export const getEventCalendarByMonth = async (month: string, year: string, familyId: string) => {
    console.log('📡 Backend: getEventCalendarByMonth called:', { month, year, familyId });

    if (!familyId) {
        console.log('❌ Backend: familyId is missing');
        return [];
    }

    // ตรวจสอบว่า month มีเลข 0 นำหน้าหรือไม่ (เช่น "03")
    const paddedMonth = month.toString().padStart(2, '0');
    const prefix = `${year}-${paddedMonth}`;
    console.log(`🔍 Backend: Searching for dates starting with "${prefix}"`);

    const snapshot = await eventsCollection
        .where('familyId', '==', familyId)
        .get();

    if (snapshot.empty) {
        console.log('❌ Backend: No events found for this familyId');
        return [];
    }

    const allDocs = snapshot.docs.map(doc => doc.data());
    const filteredDocs = allDocs.filter(data => {
        const dateStr = data.date as string;
        return dateStr && dateStr.startsWith(prefix);
    });

    const grouped: Record<string, { completed: number; missed: number; total: number }> = {};

    filteredDocs.forEach(data => {
        const date = data.date as string;
        const isDone = data.isCompleted === true || data.status === 'completed';
        const isMissed = data.status === 'missed';

        if (!grouped[date]) {
            grouped[date] = { completed: 0, missed: 0, total: 0 };
        }

        grouped[date].total++;
        if (isDone) grouped[date].completed++;
        if (isMissed) grouped[date].missed++;
    });

    const result = Object.entries(grouped).map(([date, counts]) => ({
        date,
        familyId,
        completedCount: counts.completed,
        missedCount: counts.missed,
        totalCount: counts.total,
    }));

    return result;
};