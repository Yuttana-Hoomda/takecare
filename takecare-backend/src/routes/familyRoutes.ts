import { Router } from 'express';
import type { Request, Response } from 'express';
import { createFamily, linkFamily } from '../controllers/familyController.js';
import { getElderInfoByFamilyId, getElderInfoByFamilyIdSafe } from '../services/familyService.js';
import { verifyToken } from '../middlewares/middleware.js';

const router = Router();

router.post('/families', verifyToken, createFamily);
router.post('/families/link', verifyToken, linkFamily);

// GET /api/families/elder-info?familyId=xxx
router.get('/families/elder-info', async (req: Request, res: Response) => {
  try {
    const { familyId } = req.query;
    if (!familyId || typeof familyId !== 'string') {
      res.status(400).json({ error: 'familyId is required' });
      return;
    }
    const elder = await getElderInfoByFamilyIdSafe(familyId);
    res.status(200).json(elder);
  } catch (error: any) {
    console.error('getElderInfo error:', error);
    res.status(500).json({ error: error.message });
  }
});

export default router;
