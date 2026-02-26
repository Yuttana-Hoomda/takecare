import * as familyService from '../services/familyService.js';
import type { Response } from 'express';
import type { AuthRequest } from '../middlewares/middleware.js';

// ✅ ใหม่: caregiver เรียก endpoint นี้พร้อม elderUid → ระบบ link ให้อัตโนมัติ
// POST /api/families/link  body: { elderUid }
export const linkFamily = async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const caregiverUid = req.user?.uid;
        if (!caregiverUid) {
            res.status(401).json({ success: false, message: 'Unauthorized' });
            return;
        }

        const { elderUid } = req.body;
        if (!elderUid) {
            res.status(400).json({ success: false, message: 'elderUid is required' });
            return;
        }

        await familyService.linkCaregiverByElderUid(elderUid, caregiverUid);

        res.status(200).json({ success: true, message: 'เชื่อมต่อครอบครัวสำเร็จ' });
    } catch (error: any) {
        console.error('[linkFamily error]', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// เดิม: สร้าง family ด้วย elderId + caregiverId โดยตรง (เก็บไว้เผื่อใช้)
export const createFamily = async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const { elderId, caregiverId } = req.body;
        if (!elderId || !caregiverId) {
            res.status(400).json({ error: 'Elder ID and Caregiver ID are required' });
            return;
        }

        const family = await familyService.createFamily(elderId, caregiverId);
        res.status(201).json({ success: true, data: family });
    } catch (error) {
        res.status(500).json({ error: 'Failed to create family' });
    }
};
