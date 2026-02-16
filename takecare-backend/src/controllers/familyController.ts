import * as familyService from '../services/familyService.js';
import type { Request, Response } from 'express';

export const createFamily = async (req: Request, res: Response) => {
    try {
        const elderId = req.body.elderId;
        const caregiverId = req.body.caregiverId;

        if (!elderId || !caregiverId) {
            res.status(400).json({ error: 'Elder ID and Caregiver ID are required' });
            return;
        }

        const family = await familyService.createFamily(elderId, caregiverId);
        res.status(201).json(family);
    } catch (error) {
        res.status(500).json({ error: 'Failed to create family' });
    }
}

export const addCaregiverToFamily = async (req: Request, res: Response): Promise<void> => {
    try {
        const familyId = req.params.familyId as string;
        const caregiverId = req.body.caregiverId as string;

        if (!familyId || !caregiverId) {
            res.status(400).json({ error: 'Family ID and Caregiver ID are required' });
            return;
        }

        // Call the service with just the two IDs
        await familyService.addCaregiver(caregiverId, familyId);

        res.status(200).json({
            success: true,
            message: 'Caregiver successfully added to the family'
        });

    } catch (error: any) {
        console.error(`[Controller Error] Failed to link caregiver to family ${req.params.familyId}:`, error);
        res.status(500).json({ error: 'Failed to update family connection' });
    }
}