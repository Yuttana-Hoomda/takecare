import admin from 'firebase-admin';
import { db } from '../config/firebase.js';
import type { UserProfile, CreateUserDTO } from '../models/userModel.js';

const usersCollection = db.collection('users');

export const createUserProfile = async (userData: CreateUserDTO): Promise<UserProfile> => {
    const newUser: UserProfile = {
        ...userData,
        createdAt: admin.firestore.Timestamp.now(),
    };

    await usersCollection.add(newUser);
    return newUser;
};

export const getUserProfileByUid = async (uid: string): Promise<UserProfile | null> => {
    const snapshot = await usersCollection
        .where('uid', '==', uid)
        .limit(1)
        .get();

    if (snapshot.empty) return null;

    const doc = snapshot.docs[0];
    return doc ? (doc.data() as UserProfile) : null;
};

// ✅ ใหม่: ค้นหา user จากเบอร์โทร
export const getUserByPhone = async (phone: string): Promise<UserProfile | null> => {
    const snapshot = await usersCollection
        .where('phoneNumber', '==', phone)
        .limit(1)
        .get();

    if (snapshot.empty) return null;

    const doc = snapshot.docs[0];
    return doc ? (doc.data() as UserProfile) : null;
};
