import type { Request, Response } from 'express';
import { analyzeFood, saveAnalysis } from '../services/foodAnalysisService.js';

export const analyzeFoodImage = async (req: Request, res: Response): Promise<void> => {
    try {
        const { img } = req.body;
        const { disease } = req.body;

        if (!img) {
            res.status(400).json({ success: false, message: 'img (base64) is required' });
            return;
        }

        // Strip base64 header if present e.g. "data:image/jpeg;base64,..."
        const base64Data = img.includes(',') ? img.split(',')[1] : img;

        const result = await analyzeFood(base64Data, disease);

        res.status(200).json(result);
    } catch (error: any) {
        console.error('[Controller] Food analysis error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Analysis failed',
        });
    }
};

export const saveFoodAnalysis = async (req: Request, res: Response): Promise<void> => {
    try {
        const { elderlyId, familyId, imageUrl, analysisResult } = req.body;

        if (!elderlyId || !familyId || !imageUrl || !analysisResult) {
            res.status(400).json({
                success: false,
                message: 'Missing required fields: elderlyId, familyId, imageUrl, analysisResult',
            });
            return;
        }

        const analysisId = await saveAnalysis({ elderlyId, familyId, imageUrl, analysisResult });

        res.status(201).json({
            success: true,
            data: { analysisId },
        });
    } catch (error: any) {
        console.error('[Controller] Save analysis error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Save failed',
        });
    }
};