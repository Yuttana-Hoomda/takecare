import type { Response } from 'express';
import type { AuthRequest } from '../middlewares/middleware.js';
import * as userService from '../services/userService.js';
import type { CaregiverProfile, CreateUserDTO, ElderProfile, MealSchedule } from '../models/userModel.js';

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

        const { role, displayName, phoneNumber, profileImgUrl, familyId, ncdConditions, foodTime } = req.body;

        // 1. Validate required base fields
        if (!displayName || !phoneNumber) {
            res.status(400).json({ success: false, message: 'displayName and phoneNumber are required' });
            return;
        }

        // 2. Validate role is allowed
        const assignedRole = role || 'pending';
        if (assignedRole !== 'elder' && assignedRole !== 'caregiver' && assignedRole !== 'pending') {
            res.status(400).json({ success: false, message: 'role must be elder, caregiver, or pending' });
            return;
        }

        // 3. Create the base profile exactly ONCE. 
        // Using ?? '' ensures it is NEVER undefined.
        let profileData: any = {
            uid,
            role: assignedRole,
            displayName,
            phoneNumber,
            profileImgUrl: profileImgUrl ?? '',
            familyId: familyId ?? '',
        };

        // 4. Add Elder-specific data ONLY if they are an elder
        if (assignedRole === 'elder') {
            if (!foodTime || !foodTime.breakfast || !foodTime.lunch || !foodTime.dinner) {
                res.status(400).json({
                    success: false,
                    message: 'foodTime (breakfast, lunch, dinner) is required for elder role',
                });
                return;
            }
            profileData.ncdConditions = ncdConditions ?? [];
            profileData.foodTime = foodTime;
        }
        // Notice: There is NO `else` block here anymore! 
        // Caregivers and Pending users just use the base profileData from Step 3.

        // 5. Save to database
        const newProfile = await userService.createUserProfile(profileData);
        res.status(201).json({ success: true, data: newProfile });

    } catch (error: any) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const updateProfile = async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const uid = req.user?.uid;
        if (!uid) {
            res.status(401).json({ success: false, message: 'Unauthorized' });
            return;
        }

        const updatedData: Partial<ElderProfile> | Partial<CaregiverProfile> = req.body;

        const updatedProfile = await userService.updateUserProfile(uid, updatedData);
        if (!updatedProfile) {
            res.status(404).json({ success: false, message: 'User not found' });
            return;
        }

        res.status(200).json({ success: true, data: updatedProfile });
    } catch (error: any) {
        res.status(500).json({ success: false, message: error.message });
    }
};

//  ใหม่: ค้นหา user จากเบอร์โทร (สำหรับ caregiver ค้นหา elder)
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
