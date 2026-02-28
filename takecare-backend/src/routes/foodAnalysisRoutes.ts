import { Router } from "express";
import { analyzeFoodImage, saveFoodAnalysis } from "../controllers/foodAnalysisController.js";

const router = Router();

// Analyze image — AI only, nothing saved to DB
router.post('/analyze', analyzeFoodImage);

// Save — only when user confirms
router.post('/save', saveFoodAnalysis);

export default router;