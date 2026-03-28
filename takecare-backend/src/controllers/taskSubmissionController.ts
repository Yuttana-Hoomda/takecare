import type { Request, Response } from 'express';
import { createTaskSubmission } from '../services/taskSubmissionService.js';

export const submitTaskController = async (req: Request, res: Response) => {
    try {
        // Extract the new title/subtitle fields
        const { taskId, elderlyId, familyId, proofImgUrl, displayTitle, displaySubtitle } = req.body;

        if (!taskId || !elderlyId || !familyId || !displayTitle) {
            return res.status(400).json({
                success: false,
                message: "taskId, elderlyId, familyId, and displayTitle are required."
            });
        }

        // Pass all data to the updated service
        const submissionResult = await createTaskSubmission({
            taskId,
            elderlyId,
            familyId,
            proofImgUrl: proofImgUrl || null,
            displayTitle,
            displaySubtitle
        });

        return res.status(201).json({
            success: true,
            message: "Task submission and event recorded successfully.",
            data: submissionResult
        });

    } catch (error) {
        console.error("Error creating task submission:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error while submitting task."
        });
    }
};