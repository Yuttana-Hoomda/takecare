import admin from 'firebase-admin';
import { db } from '../config/firebase.js';
import type { UserProfile, CreateUserDTO } from '../models/userModel.js';

const usersCollection = db.collection('users');

export const createUserProfile = async (userData: CreateUserDTO): Promise<UserProfile> => {
    const newUser: UserProfile = {
        ...userData,
        createdAt: admin.firestore.Timestamp.now(),
    };

    return newUser;
};

export const getUserProfileByUid = async (uid: string): Promise<UserProfile | null> => {
    const snapshot = await usersCollection
        .where('uid', '==', uid)
        .limit(1)
        .get();

    if (snapshot.empty) {
        return null;
    }

    const doc = snapshot.docs[0];
    return doc ? (doc.data() as UserProfile) : null;
};