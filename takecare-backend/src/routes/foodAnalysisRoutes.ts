import { Router } from "express";
import { analyzeFoodImage, getFoodAnalysis, saveFoodAnalysis } from "../controllers/foodAnalysisController.js";

const router = Router();

// Analyze image — AI only, nothing saved to DB
router.post('/analyze', analyzeFoodImage);

// Save — only when user confirms
router.post('/save', saveFoodAnalysis);
router.get('/food/:foodId', getFoodAnalysis);

export default router;