export interface Event {
  date: string; // Format: YYYY-MM-DD
  elderlyId: string;
  familyId: string;
  referenceId: String;
  referenceCollection: 'task_submission' | 'food_analyses';
  displayTitle: String,
  displaySubtitle: String | null,
  thumbnailUrl: String | null,
  type: 'task' | 'foodAnalysis';
  status: 'missed' | 'completed';
  createdAt: Date;
}