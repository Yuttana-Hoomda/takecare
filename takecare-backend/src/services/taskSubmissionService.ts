import { db } from "../config/firebase.js";
import { FieldValue } from 'firebase-admin/firestore';

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

    // 1. Create the Task Submission Document
    const submissionRef = db.collection('task_submissions').doc();
    await submissionRef.set({
        taskId: data.taskId,
        elderlyId: data.elderlyId,
        familyId: data.familyId,
        proofImgUrl: data.proofImgUrl,
        createdAt: FieldValue.serverTimestamp(),
    });

    const dateString = new Date().toISOString().slice(0, 10);

    // 2. Create the Event Document
    const eventRef = db.collection('events').doc();
    await eventRef.set({
        date: dateString,
        elderlyId: data.elderlyId,
        familyId: data.familyId,
        referenceId: submissionRef.id,
        type: 'taskSubmission', // Specific type for the UI to handle differently if needed
        referenceCollection: 'task_submissions',
        displayTitle: data.displayTitle,
        displaySubtitle: data.displaySubtitle || 'Task Completed',
        thumbnailUrl: data.proofImgUrl,
        status: 'completed',
        createdAt: FieldValue.serverTimestamp(),
    });

    // 3. Update the Event Calendar Summary
    const calendarDocId = `${data.elderlyId}_${dateString}`;
    await db.collection('event_calendar').doc(calendarDocId).set({
        Date: dateString,
        elderlyId: data.elderlyId,
        familyId: data.familyId,
        completedCount: FieldValue.increment(1),
        // Note: I included totalCount to match your saveAnalysis logic. 
        // If tasks are pre-scheduled, you might only want to increment completedCount here.
        totalCount: FieldValue.increment(1)
    }, { merge: true });

    return { submissionId: submissionRef.id, eventId: eventRef.id };
}