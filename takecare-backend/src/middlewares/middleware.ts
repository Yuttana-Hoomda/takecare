import type { Request, Response, NextFunction } from 'express';
import { auth } from '../config/firebase.js';
import admin from 'firebase-admin';

export interface AuthRequest extends Request {
    user?: admin.auth.DecodedIdToken;
}

export const verifyToken = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        res.status(401).json({ error: 'Unauthorized: No token provided' });
        return;
    }

    const idToken = authHeader.split('Bearer ')[1];

    if (!idToken) {
        res.status(401).json({ error: 'Unauthorized: No token provided' });
        return;
    }

    try {
        const decodedToken = await auth.verifyIdToken(idToken);
        req.user = decodedToken; // Attach the verified user to the request
        next();
    } catch (error) {
        console.error('Error verifying auth token:', error);
        res.status(403).json({ error: 'Unauthorized: Invalid or expired token' });
    }
};