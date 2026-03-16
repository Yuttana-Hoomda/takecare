export interface TaskSubmission {
  taskId: string;
  elderlyId: string;
  familyId: string;
  proofImgUrl: string | null;
  submittedDate: string; // "YYYY-MM-DD" ใช้ query ง่าย
  createdAt: string;
}
