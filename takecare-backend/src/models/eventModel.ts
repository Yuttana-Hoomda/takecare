import type { Timestamp } from "firebase-admin/firestore";

export interface Event {
    id?: string;
    date: string;
    elderlyId: string;
    familyId: string;
    type: string;                    // "task" | "foodAnalysis"
    referenceCollection: string;     // "task_submission" | "food_analyses"
    referenceId: string;
    displayTitle: string;
    displaySubtitle?: string | null;
    icon: string;
    status: string;                  // "completed" | "missed"
    createdAt: Timestamp | string;
}

export interface EventCalendar {
    id?: string;
    date: string;                    // "yyyy-MM-dd"
    elderlyId: string;
    familyId: string;
    completedCount: number;
    missedCount: number;
    totalCount: number;
}