import type { Request, Response } from 'express';
import * as submissionService from '../missing-task/taskSubmissionService.js';

export const createSubmission = async (req: Request, res: Response): Promise<void> => {
  try {
    const { taskId, elderlyId, familyId, proofImgUrl, taskTitle } = req.body;

    if (!taskId || !elderlyId || !familyId || !taskTitle) {
      res.status(400).json({ success: false, message: 'taskId, elderlyId, familyId, taskTitle are required' });
      return;
    }

    const submission = await submissionService.createSubmission({
      taskId,
      elderlyId,
      familyId,
      proofImgUrl: proofImgUrl ?? null,
      taskTitle,
    });

    res.status(201).json(submission);
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getSubmissionsByFamily = async (req: Request, res: Response): Promise<void> => {
  try {
    const { familyId } = req.params;
    const { date } = req.query;

    if (!familyId) {
      res.status(400).json({ success: false, message: 'familyId is required' });
      return;
    }

    const submissions = await submissionService.getSubmissionsByFamily(
      familyId,
      date as string | undefined,
    );

    res.status(200).json(submissions);
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};
