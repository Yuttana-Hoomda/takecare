import { db } from '../config/firebase.js';

const tasksCollection       = db.collection('tasks');
const submissionsCollection = db.collection('task_submissions');
const eventsCollection      = db.collection('events');

const getJsWeekday = (date: Date): number => date.getDay();
const toDateString = (date: Date): string => date.toISOString().split('T')[0];

export const checkMissingTasks = async (): Promise<void> => {
  const now = new Date();
  const todayStr = toDateString(now);
  const jsWeekday = getJsWeekday(now);

  console.log(`🔍 checkMissingTasks: ${todayStr} weekday=${jsWeekday}`);

  const taskSnapshot = await tasksCollection
    .where('isRequiredPhoto', '==', true)
    .get();

  console.log(`📋 Found ${taskSnapshot.size} isRequiredPhoto tasks`);

  if (taskSnapshot.empty) {
    console.log('No requirePhoto tasks found');
    return;
  }

  for (const taskDoc of taskSnapshot.docs) {
    const task = taskDoc.data();
    const taskId = taskDoc.id;

    console.log(`\n🔎 task: ${task.title} | hour:${task.time?.hour} min:${task.time?.minute} | repeatDays:${JSON.stringify(task.repeatDays)}`);

    // เช็ค repeatDays
    const repeatDays: number[] = task.repeatDays ?? [];
    if (repeatDays.length > 0 && !repeatDays.includes(jsWeekday)) {
      console.log(`   ⏭️ skip: วันนี้ไม่ใช่วันที่ต้องทำ (jsWeekday=${jsWeekday})`);
      continue;
    }

    // เช็คว่าเลยเวลามา 1 นาที (เทส)
    const taskHour: number   = task.time?.hour ?? 0;
    const taskMinute: number = task.time?.minute ?? 0;

    const taskTime = new Date(`${todayStr}T${String(taskHour).padStart(2,'0')}:${String(taskMinute).padStart(2,'0')}:00+07:00`);

    const diffMs = now.getTime() - taskTime.getTime();
    const diffMinutes = diffMs / (1000 * 60);

    console.log(`   ⏱️ diffMinutes: ${diffMinutes.toFixed(1)}`);

    // ✅ เทสใช้ 1 นาที — production เปลี่ยนเป็น diffMinutes < 60
    if (diffMinutes < 1) {
      console.log(`   ⏭️ skip: ยังไม่เลย 1 นาที`);
      continue;
    }

    // เช็คว่ามี submission วันนี้ไหม
    const submissionSnapshot = await submissionsCollection
      .where('taskId', '==', taskId)
      .where('submittedDate', '==', todayStr)
      .limit(1)
      .get();

    if (!submissionSnapshot.empty) {
      console.log(`   ⏭️ skip: มี submission แล้ว`);
      continue;
    }

    // เช็ค duplicate missed event
    const existingEvent = await eventsCollection
      .where('referenceId', '==', taskId)
      .where('date', '==', todayStr)
      .where('status', '==', 'missed')
      .limit(1)
      .get();

    if (!existingEvent.empty) {
      console.log(`   ⏭️ skip: มี missed event แล้ว`);
      continue;
    }

    // สร้าง missed event
    await eventsCollection.add({
      date:                todayStr,
      elderlyId:           task.assignTo ?? '',
      familyId:            task.familyId,
      referenceId:         taskId,
      referenceCollection: 'task_submissions',
      displayTitle:        task.title,
      displaySubtitle:     'ไม่ได้ทำ',
      thumbnailUrl:        null,
      type:                'task',
      status:              'missed',
      createdAt:           new Date().toISOString(),
    });

    console.log(`❌ Marked missed: ${task.title} (${taskId}) on ${todayStr}`);
  }

  console.log('✅ checkMissingTasks done');
};