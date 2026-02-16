import type { Timestamp } from "firebase-admin/firestore";

export interface Task {
    taskId?: string;
    createdBy: string;
    familyId: string;
    title: string;
    type: string;
    details: Map<string, any>;
    time: {
        hour: number,
        minute: number
    }
    repeatDays?: number[];
    requiredPhotos?: boolean;
    createdAt: Timestamp;
}