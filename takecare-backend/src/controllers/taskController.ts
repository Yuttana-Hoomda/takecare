import type { Request, Response } from 'express';
import * as taskService from '../services/taskService.js';

export const createTask = async (req: Request, res: Response): Promise<void> => {
    try {
        const taskPayload = req.body;

        if (!taskPayload) {
            res.status(400).json({ success: false, message: 'Task data is required' });
            return;
        }

        const created = await taskService.createTask(taskPayload);
        res.status(201).json(created);
    } catch (error: any) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const getTasksForFamily = async (req: Request, res: Response): Promise<void> => {
    try {
        const familyId = req.params.familyId as string;

        if (!familyId) {
            res.status(400).json({ success: false, message: 'familyId is required' });
            return;
        }

        const tasks = await taskService.getTasksForFamily(familyId);
        res.status(200).json(tasks);
    } catch (error: any) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const updateTask = async (req: Request, res: Response): Promise<void> => {
    try {
        const taskId = req.params.taskId as string;
        const updatedData = req.body;

        if (!taskId) {
            res.status(400).json({ success: false, message: 'taskId is required' });
            return;
        }

        if (!updatedData || Object.keys(updatedData).length === 0) {
            res.status(400).json({ success: false, message: 'updated data is required' });
            return;
        }

        const updated = await taskService.updateTask(taskId, updatedData);
        res.status(200).json({ success: true, data: updated });
    } catch (error: any) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const deleteTask = async (req: Request, res: Response): Promise<void> => {
    try {
        const taskId = req.params.taskId as string;

        if (!taskId) {
            res.status(400).json({ success: false, message: 'taskId is required' });
            return;
        }

        await taskService.deleteTask(taskId);
        res.status(200).json({ success: true, message: 'Task deleted' });
    } catch (error: any) {
        res.status(500).json({ success: false, message: error.message });
    }
};
