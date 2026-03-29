import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../config/firebase.js';
import { uploadImageToCloudinary } from '../services/foodAnalysisService.js';

const submissionsCollection = db.collection('task_submissions');
const eventsCollection      = db.collection('events');


// Added displayTitle and displaySubtitle to map to the events collection
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
    imageUrl = await uploadImageToCloudinary(data.proofImgUrl); // TypeScript now knows this is safe!
    console.log('[Cloudinary] Upload success:', imageUrl);
  }
  // 1. Create the Task Submission Document
  const submissionRef = db.collection('task_submissions').doc();
  await submissionRef.set({
    taskId: data.taskId,
    elderlyId: data.elderlyId,
    familyId: data.familyId,
    proofImgUrl: imageUrl,
    createdAt: FieldValue.serverTimestamp(),
  });

  const dateString = new Date().toISOString().slice(0, 10);

  // 2. Create the Event Document
  const eventRef = eventsCollection.doc();
  await eventRef.set({
    date: dateString,
    elderlyId: data.elderlyId,
    familyId: data.familyId,
    referenceId: submissionRef.id,
    type: 'taskSubmission', // Specific type for the UI to handle differently if needed
    referenceCollection: 'task_submissions',
    displayTitle: data.displayTitle,
    displaySubtitle: data.displaySubtitle || 'Task Completed',
    status: 'completed',
    createdAt: FieldValue.serverTimestamp(),
  });

  // 3. Update the Event Calendar Summary
  // 3. Update the Event Calendar Summary
  const calendarDocId = `${data.elderlyId}_${dateString}`;
  const calendarRef = db.collection('event_calendar').doc(calendarDocId);
  const calendarSnap = await calendarRef.get();

  if (!calendarSnap.exists) {
    // ✅ First submission of the day — create fresh document
    await calendarRef.set({
      date: dateString,
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
}

export const getSubmissionsByFamily = async (familyId: string, date?: string) => {
  let query = submissionsCollection.where('familyId', '==', familyId);

  if (date) {
    query = query.where('submittedDate', '==', date) as any;
  }

  const snapshot = await query.get();
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
};
