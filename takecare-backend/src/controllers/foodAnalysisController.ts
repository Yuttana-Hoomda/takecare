import type { Request, Response } from 'express';
import { analyzeFood, getFoodAnalysisById, saveAnalysis } from '../services/foodAnalysisService.js';
import type { SaveAnalysisRequest } from '../models/foodAnalysisModel.js';
import type { NCDisease } from '../models/userModel.js';

export const analyzeFoodImage = async (req: Request, res: Response): Promise<void> => {
    try {
        const { img, disease } = req.body;

        if (!img) {
            res.status(400).json({ success: false, message: 'img (base64) is required' });
            return;
        }

        // Validate disease array
        if (disease !== undefined && disease !== null) {
            if (!Array.isArray(disease)) {
                res.status(400).json({
                    success: false,
                    message: 'disease must be an array e.g. ["diabetes", "hypertension"]',
                });
                return;
            }

            const validDiseases: NCDisease[] = ['diabetes', 'hypertension'];
            const invalid = disease.filter((d: any) => !validDiseases.includes(d));
            if (invalid.length > 0) {
                res.status(400).json({
                    success: false,
                    message: `Invalid disease values: ${invalid.join(', ')}. Must be "diabetes" or "hypertension"`,
                });
                return;
            }
        }

        const result = await analyzeFood(img, disease ?? null);
        res.status(200).json(result);
    } catch (error: any) {
        console.error('[Controller] Food analysis error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Analysis failed',
        });
    }
};

export const saveFoodAnalysis = async (req: Request, res: Response) => {
    try {
        const { elderlyId, familyId, imageBase64, analysisResult, displayTitle } = req.body;

        const data: SaveAnalysisRequest = {
            elderlyId,
            familyId,
            imageBase64,
            analysisResult,
        };

        const { foodId, eventId } = await saveAnalysis(data, displayTitle);

        res.status(201).json({ foodId, eventId });

    } catch (error) {
        console.error('[analyzeFood] Error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to save analysis',
        });
    }
};

export const getFoodAnalysis = async (req: Request, res: Response): Promise<void> => {
    try {
        const foodId = req.params.foodId as string;

        if (!foodId) {
            res.status(400).json({ success: false, message: 'foodId is required' });
            return;
        }

        const result = await getFoodAnalysisById(foodId);

        if (!result) {
            res.status(404).json({ success: false, message: 'Food analysis not found' });
            return;
        }

        res.status(200).json(result);
    } catch (error) {
        console.error('[getFoodAnalysis] Error:', error);
        res.status(500).json({ success: false, message: 'Failed to get food analysis' });
    }
};