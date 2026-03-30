import { db } from "../config/firebase.js";

const eventsCollection = db.collection('events');
const tasksCollection = db.collection('tasks');

// GET /api/event?date=2026-03-15&familyId=xxx
export const getEventsByDate = async (date: string, familyId: string) => {
    const snapshot = await eventsCollection
        .where('familyId', '==', familyId)
        .get();

    if (snapshot.empty) return [];

    const events = snapshot.docs
        .map(doc => ({ id: doc.id, ...doc.data() }))
        .filter((data: any) => data.date === date);

    // dedup ด้วย referenceId — เก็บแค่อันล่าสุดของแต่ละ task
    const dedupMap = new Map<string, any>();
    for (const event of events) {
        const key = (event as any).referenceId ?? (event as any).id;
        const existing = dedupMap.get(key);
        if (!existing || (event as any).createdAt > existing.createdAt) {
            dedupMap.set(key, event);
        }
    }
    const dedupedEvents = Array.from(dedupMap.values());

    // ดึง isRequiredPhoto จาก tasks collection มาแนบกับแต่ละ event
    const eventsWithPhoto = await Promise.all(
        dedupedEvents.map(async (event: any) => {
            if (event.type === 'task' && event.referenceId) {
                try {
                    const taskDoc = await tasksCollection.doc(event.referenceId).get();
                    if (taskDoc.exists) {
                        const taskData = taskDoc.data();
                        return {
                            ...event,
                            isRequiredPhoto: taskData?.isRequiredPhoto ?? false,
                        };
                    }
                } catch (e) {
                    console.error(`Failed to fetch task ${event.referenceId}:`, e);
                }
            }
            return {
                ...event,
                isRequiredPhoto: false,
            };
        })
    );

    return eventsWithPhoto;
};

// GET /api/event-calendar?month=03&year=2026&familyId=xxx
export const getEventCalendarByMonth = async (month: string, year: string, familyId: string) => {
    console.log('📡 Backend: getEventCalendarByMonth called:', { month, year, familyId });

    if (!familyId) {
        console.log('❌ Backend: familyId is missing');
        return [];
    }

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