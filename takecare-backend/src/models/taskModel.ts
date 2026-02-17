import type { Timestamp } from "firebase-admin/firestore";

export interface Task {
    taskId?: string;
    createdBy: string;
    familyId: string;
    title: string;
    date?: Timestamp;
    note?: string;
    time: {
        hour: number,
        minute: number
    }
    repeatDays?: number[];
    isRequiredPhoto?: boolean;
    isRepeatByDate?: boolean
    createdAt: Timestamp;
}