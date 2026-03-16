import { db } from '../config/firebase.js';

const submissionsCollection = db.collection('task_submissions');
const eventsCollection      = db.collection('events');

const toDateString = (date: Date): string => date.toISOString().split('T')[0];

export const createSubmission = async (data: {
  taskId: string;
  elderlyId: string;
  familyId: string;
  proofImgUrl: string | null;
  taskTitle: string;
}) => {
  const now = new Date();
  const todayStr = toDateString(now);

  // save task_submission
  const docRef = submissionsCollection.doc();
  const submission = {
    id:            docRef.id,
    taskId:        data.taskId,
    elderlyId:     data.elderlyId,
    familyId:      data.familyId,
    proofImgUrl:   data.proofImgUrl ?? null,
    submittedDate: todayStr,
    createdAt:     now.toISOString(),
  };
  await docRef.set(submission);

  // save event status: completed
  await eventsCollection.add({
    date:                todayStr,
    elderlyId:           data.elderlyId,
    familyId:            data.familyId,
    referenceId:         docRef.id,
    referenceCollection: 'task_submissions',
    displayTitle:        data.taskTitle,
    displaySubtitle:     'ทำเสร็จแล้ว',
    thumbnailUrl:        data.proofImgUrl ?? null,
    type:                'task',
    status:              'completed',
    createdAt:           now.toISOString(),
  });

  console.log(`✅ Submission created: ${data.taskTitle} by ${data.elderlyId}`);
  return submission;
};

export const getSubmissionsByFamily = async (familyId: string, date?: string) => {
  let query = submissionsCollection.where('familyId', '==', familyId);

  if (date) {
    query = query.where('submittedDate', '==', date) as any;
  }

  const snapshot = await query.get();
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
};
