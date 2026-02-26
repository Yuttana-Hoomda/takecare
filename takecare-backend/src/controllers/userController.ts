import type { Response } from 'express';
import type { AuthRequest } from '../middlewares/middleware.js';
import * as userService from '../services/userService.js';

export const getProfile = async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const uid = req.user?.uid;
        if (!uid) {
            res.status(401).json({ success: false, message: 'Unauthorized' });
            return;
        }

        const userProfile = await userService.getUserProfileByUid(uid);

        if (!userProfile) {
            res.status(404).json({ success: false, message: 'User profile not found in database.' });
            return;
        }

        res.status(200).json({ success: true, data: userProfile });
    } catch (error: any) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const createProfile = async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const uid = req.user?.uid;
        if (!uid) {
            res.status(401).json({ success: false, message: 'Unauthorized' });
            return;
        }

        const profileData = { ...req.body, uid };
        const newProfile = await userService.createUserProfile(profileData);
        res.status(201).json({ success: true, data: newProfile });
    } catch (error: any) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// ✅ ใหม่: ค้นหา user จากเบอร์โทร (สำหรับ caregiver ค้นหา elder)
export const searchUserByPhone = async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const phone = req.query.phone as string;

        if (!phone) {
            res.status(400).json({ success: false, message: 'phone query param is required' });
            return;
        }

        const user = await userService.getUserByPhone(phone);

        if (!user) {
            res.status(404).json({ success: false, message: 'ไม่พบผู้ใช้งานหมายเลขนี้' });
            return;
        }

        // Return เฉพาะข้อมูลที่จำเป็น ไม่ส่ง sensitive data ทั้งหมด
        res.status(200).json({
            success: true,
            data: {
                uid: user.uid,
                displayName: user.displayName,
                phoneNumber: user.phoneNumber,
                profileImgUrl: user.profileImgUrl,
            },
        });
    } catch (error: any) {
        res.status(500).json({ success: false, message: error.message });
    }
};
