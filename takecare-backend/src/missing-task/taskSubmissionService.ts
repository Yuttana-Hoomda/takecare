import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../config/firebase.js';
import { uploadImageToCloudinary } from '../services/foodAnalysisService.js';

const submissionsCollection = db.collection('task_submissions');
const eventsCollection = db.collection('events');

const toDateString = (date: Date): string => {
  // Bangkok timezone (UTC+7)
  const bkk = new Date(date.getTime() + 7 * 60 * 60 * 1000);
  return `${bkk.getUTCFullYear()}-${String(bkk.getUTCMonth() + 1).padStart(2, '0')}-${String(bkk.getUTCDate()).padStart(2, '0')}`;
};

export interface TaskSubmissionPayload {
  taskId: string;
  elderlyId: string;
  familyId: string;
  proofImgUrl: string | null;
  displayTitle: string;
  displaySubtitle?: string;
}

export const createTaskSubmission = async (data: TaskSubmissionPayload): Promise<{ submissionId: string, eventId: string }> => {
  let imageUrl: string | null = null;

  if (data.proofImgUrl) {
    console.log('[Cloudinary] Uploading image...');
    imageUrl = await uploadImageToCloudinary(data.proofImgUrl);
    console.log('[Cloudinary] Upload success:', imageUrl);
  }

  const now = new Date();
  const todayStr = toDateString(now);

  // 1. Create the Task Submission Document
  const submissionRef = db.collection('task_submissions').doc();
  await submissionRef.set({
    taskId: data.taskId,
    elderlyId: data.elderlyId,
    familyId: data.familyId,
    proofImgUrl: imageUrl,
    createdAt: FieldValue.serverTimestamp(),
  });

  // 2. Create the Event Document
  const eventRef = eventsCollection.doc();
  await eventRef.set({
    date: todayStr,
    elderlyId: data.elderlyId,
    familyId: data.familyId,
    taskId: data.taskId,
    referenceId: submissionRef.id,
    referenceCollection: 'task_submissions',
    displayTitle: data.displayTitle,
    displaySubtitle: data.displaySubtitle ?? 'ทำเสร็จแล้ว',
    thumbnailUrl: imageUrl ?? null,
    type: 'task',
    status: 'completed',
    createdAt: now.toISOString(),
  });

  // 3. Update the Event Calendar Summary
  const calendarDocId = `${data.elderlyId}_${todayStr}`;
  const calendarRef = db.collection('event_calendar').doc(calendarDocId);
  const calendarSnap = await calendarRef.get();

  if (!calendarSnap.exists) {
    // First submission of the day — create fresh document
    await calendarRef.set({
      date: todayStr,
      elderlyId: data.elderlyId,
      familyId: data.familyId,
      completedCount: 1,
      totalCount: 1,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
  } else {
    await calendarRef.update({
      completedCount: FieldValue.increment(1),
      totalCount: FieldValue.increment(1),
      updatedAt: FieldValue.serverTimestamp(),
    });
  }

  return { submissionId: submissionRef.id, eventId: eventRef.id };
};

export const getSubmissionsByFamily = async (familyId: string, date?: string) => {
  let query = submissionsCollection.where('familyId', '==', familyId);

  if (date) {
    query = query.where('submittedDate', '==', date) as any;
  }

  const snapshot = await query.get();
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
};