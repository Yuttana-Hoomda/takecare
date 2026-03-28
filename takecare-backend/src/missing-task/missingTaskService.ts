import { db } from '../config/firebase.js';

const tasksCollection       = db.collection('tasks');
const submissionsCollection = db.collection('task_submissions');
const eventsCollection      = db.collection('events');
const familiesCollection    = db.collection('family');

// ✅ Bangkok timezone helper (UTC+7)
const getBangkokNow = (): Date => {
  const utc = new Date();
  return new Date(utc.getTime() + 7 * 60 * 60 * 1000);
};

const toDateString = (date: Date): string =>
  `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, '0')}-${String(date.getUTCDate()).padStart(2, '0')}`;

const getJsWeekday = (date: Date): number => date.getUTCDay();

// [FIX 2] cache elderlyId ต่อ familyId เพื่อไม่ต้อง query ซ้ำทุก task
const familyElderCache: Record<string, string> = {};

const getElderlyIdByFamilyId = async (familyId: string): Promise<string> => {
  if (familyElderCache[familyId]) return familyElderCache[familyId];

  const snapshot = await familiesCollection
    .where('familyId', '==', familyId)
    .limit(1)
    .get();

  // ลอง doc id ด้วย เผื่อ familyId คือ doc id
  if (snapshot.empty) {
    const docSnap = await familiesCollection.doc(familyId).get();
    if (docSnap.exists) {
      const elderlyId = docSnap.data()?.elder ?? '';
      familyElderCache[familyId] = elderlyId;
      return elderlyId;
    }
    return '';
  }

  const elderlyId = snapshot.docs[0]!.data().elder ?? '';
  familyElderCache[familyId] = elderlyId;
  return elderlyId;
};

const shouldRunToday = (task: FirebaseFirestore.DocumentData, todayStr: string, jsWeekday: number): boolean => {
  if (task.date && task.date !== '') {
    return task.date === todayStr;
  }
  const repeatDays: number[] = task.repeatDays ?? [];
  if (repeatDays.length === 0) return true;
  return repeatDays.includes(jsWeekday);
};

export const checkMissingTasks = async (): Promise<void> => {
  const now        = getBangkokNow();
  const todayStr   = toDateString(now);
  const jsWeekday  = getJsWeekday(now);
  const nowMinutes = now.getUTCHours() * 60 + now.getUTCMinutes();

  console.log(`checkMissingTasks: ${todayStr} weekday=${jsWeekday} time=${String(now.getUTCHours()).padStart(2,'0')}:${String(now.getUTCMinutes()).padStart(2,'0')} BKK`);

  const taskSnapshot = await tasksCollection.get();
  console.log(`Found ${taskSnapshot.size} total tasks`);
  if (taskSnapshot.empty) return;

  for (const taskDoc of taskSnapshot.docs) {
    const task   = taskDoc.data();
    const taskId = taskDoc.id;

    if (!shouldRunToday(task, todayStr, jsWeekday)) continue;

    const taskHour: number   = task.time?.hour ?? 0;
    const taskMinute: number = task.time?.minute ?? 0;
    const taskMinutes        = taskHour * 60 + taskMinute;
    const diffMinutes        = nowMinutes - taskMinutes;

    if (diffMinutes < 60) continue;

    // check submission
    const submissionSnapshot = await submissionsCollection
      .where('taskId', '==', taskId)
      .where('submittedDate', '==', todayStr)
      .limit(1)
      .get();

    if (!submissionSnapshot.empty) continue;

    // [FIX 1] check duplicate โดยใช้ taskId field ตรงๆ แทน referenceId
    // เพราะ referenceId ใน completed events เป็น submissionId ไม่ใช่ taskId
    const existingEvent = await eventsCollection
      .where('taskId', '==', taskId)
      .where('date', '==', todayStr)
      .where('status', '==', 'missed')
      .limit(1)
      .get();

    if (!existingEvent.empty) continue;

    // [FIX 2] ดึง elderlyId จาก family collection แทนการใช้ task.assignTo
    const elderlyId = await getElderlyIdByFamilyId(task.familyId ?? '');

    await eventsCollection.add({
      date:                todayStr,
      elderlyId:           elderlyId,           // ✅ ได้ค่าจริงแล้ว
      familyId:            task.familyId ?? '',
      taskId:              taskId,              // ✅ เพิ่ม field นี้เพื่อ check duplicate ได้ถูกต้อง
      referenceId:         taskId,
      referenceCollection: 'tasks',
      displayTitle:        task.title ?? '',
      displaySubtitle:     'ไม่ได้ทำ',
      thumbnailUrl:        null,
      type:                'task',
      status:              'missed',
      createdAt:           new Date().toISOString(),
    });

    console.log(`Marked missed: ${task.title} (${taskId}) on ${todayStr} | elder: ${elderlyId}`);
  }

  console.log('checkMissingTasks done');
};