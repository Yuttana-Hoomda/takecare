import type { Response } from 'express';
import type { AuthRequest } from '../middlewares/middleware.js';
import * as userService from '../services/userService.js';

export const getProfile = async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const uid = req.user?.uid;
        if (!uid) {
            res.status(401).json({ success: false, message: "Unauthorized" });
            return;
        }

        const userProfile = await userService.getUserProfileByUid(uid);

        if (!userProfile) {
            res.status(404).json({ success: false, message: "User profile not found in database." });
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
            res.status(401).json({ success: false, message: "Unauthorized" });
            return;
        }

        // Combine the secure UID with the profile details sent from the Flutter app
        const profileData = {
            ...req.body,
            uid: uid,
        };

        const newProfile = await userService.createUserProfile(profileData);
        res.status(201).json({ success: true, data: newProfile });
    } catch (error: any) {
        res.status(500).json({ success: false, message: error.message });
    }
};