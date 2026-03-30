import { db } from '../config/firebase.js';

const eventsCollection = db.collection('events');
const tasksCollection  = db.collection('tasks');

export interface DailySummary {
  date: string;
  totalCount: number;
  completedCount: number;
  missedCount: number;
  pendingCount: number;
  completedRate: number;
}

export interface EventItem {
  id: string;
  displayTitle: string;
  displaySubtitle: string | null;
  status: 'completed' | 'missed' | 'pending';
  type: string;
  thumbnailUrl: string | null;
  createdAt: string;
}

// GET daily summary
export const getDailySummary = async (familyId: string, date: string): Promise<DailySummary> => {
  const eventSnapshot = await eventsCollection
    .where('familyId', '==', familyId)
    .where('date', '==', date)
    .where('type', '==', 'task')
    .get();

  const events = eventSnapshot.docs.map(doc => doc.data());
  const completedCount = events.filter(e => e.status === 'completed').length;
  const missedCount    = events.filter(e => e.status === 'missed').length;

  const bangkokDate = new Date(date + 'T12:00:00+07:00');
  const jsWeekday   = bangkokDate.getDay();

  const taskSnapshot = await tasksCollection
    .where('familyId', '==', familyId)
    .get();

  let totalCount = 0;
  for (const doc of taskSnapshot.docs) {
    const task = doc.data();
    if (task.date && task.date !== '') {
      if (task.date === date) totalCount++;
      continue;
    }
    const repeatDays: number[] = task.repeatDays ?? [];
    if (repeatDays.length === 0 || repeatDays.includes(jsWeekday)) {
      totalCount++;
    }
  }

  const doneCount     = completedCount + missedCount;
  const pendingCount  = Math.max(0, totalCount - doneCount);
  const completedRate = totalCount > 0 ? completedCount / totalCount : 0;

  return { date, totalCount, completedCount, missedCount, pendingCount, completedRate };
};

// GET recent events — รวม pending tasks ด้วย
export const getRecentEvents = async (familyId: string, date: string, limit = 10): Promise<EventItem[]> => {
  // 1. ดึง events ทั้งหมดของวันนั้น
  const eventSnapshot = await eventsCollection
    .where('familyId', '==', familyId)
    .where('date', '==', date)
    .get();

  const doneItems: EventItem[] = eventSnapshot.docs.map(doc => {
    const data = doc.data();
    return {
      id:              doc.id,
      displayTitle:    data.displayTitle ?? '',
      displaySubtitle: data.displaySubtitle ?? null,
      status:          data.status ?? 'pending',
      type:            data.type ?? 'task',
      thumbnailUrl:    data.thumbnailUrl ?? null,
      createdAt:       data.createdAt ?? '',
    };
  });

  // [FIX] สร้าง Set ของ taskId ที่มี event แล้ว
  // รองรับทั้ง schema ใหม่ (taskId field) และเก่า (referenceId = taskId สำหรับ missed)
  // สำหรับ completed event เก่าที่ referenceId = submissionId → ดึง taskId จาก task_submissions
  const doneTaskIds = new Set<string>();

  for (const doc of eventSnapshot.docs) {
    const data = doc.data();

    // schema ใหม่: มี taskId field ตรงๆ
    if (data.taskId) {
      doneTaskIds.add(data.taskId as string);
      continue;
    }

    // schema เก่า missed: referenceCollection = 'tasks' → referenceId คือ taskId
    if (data.referenceCollection === 'tasks') {
      doneTaskIds.add(data.referenceId as string);
      continue;
    }

    // schema เก่า completed: referenceCollection = 'task_submissions'
    // → ต้อง lookup submission เพื่อเอา taskId
    if (data.referenceCollection === 'task_submissions' && data.referenceId) {
      try {
        const submissionDoc = await db
          .collection('task_submissions')
          .doc(data.referenceId as string)
          .get();
        if (submissionDoc.exists) {
          const taskId = submissionDoc.data()?.taskId as string | undefined;
          if (taskId) doneTaskIds.add(taskId);
        }
      } catch (_) {
        // ถ้า lookup ไม่ได้ก็ข้ามไป — task จะแสดงเป็น pending (false positive ดีกว่า miss)
      }
    }
  }

  // 2. tasks ที่ยัง pending
  const bangkokDate = new Date(date + 'T12:00:00+07:00');
  const jsWeekday   = bangkokDate.getDay();

  const taskSnapshot = await tasksCollection
    .where('familyId', '==', familyId)
    .get();

  const pendingItems: EventItem[] = [];

  for (const doc of taskSnapshot.docs) {
    const task = doc.data();

    // ข้ามถ้า task นี้มี event แล้ว
    if (doneTaskIds.has(doc.id)) continue;

    let shouldRun = false;
    if (task.date && task.date !== '') {
      shouldRun = task.date === date;
    } else {
      const repeatDays: number[] = task.repeatDays ?? [];
      shouldRun = repeatDays.length === 0 || repeatDays.includes(jsWeekday);
    }

    if (!shouldRun) continue;

    const h = String(task.time?.hour ?? 0).padStart(2, '0');
    const m = String(task.time?.minute ?? 0).padStart(2, '0');

    pendingItems.push({
      id:              doc.id,
      displayTitle:    task.title ?? '',
      displaySubtitle: `${h}:${m} น.`,
      status:          'pending',
      type:            'task',
      thumbnailUrl:    null,
      createdAt:       `${date}T${h}:${m}:00+07:00`,
    });
  }

  // 3. รวม sort desc limit
  const allItems = [...doneItems, ...pendingItems];
  allItems.sort((a, b) => String(b.createdAt).localeCompare(String(a.createdAt)));
  return allItems.slice(0, limit);
};