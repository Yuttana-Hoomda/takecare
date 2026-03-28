import admin from 'firebase-admin';
import { db } from '../config/firebase.js';
import type { UserProfile, CreateUserDTO, NCDisease, ElderProfile, CaregiverProfile } from '../models/userModel.js';

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

export const updateUserProfile = async (
    uid: string,
    updatedData: Partial<ElderProfile> | Partial<CaregiverProfile>
): Promise<UserProfile | null> => {
    try {
        const snapshot = await usersCollection
            .where('uid', '==', uid)
            .limit(1)
            .get();

        if (snapshot.empty || !snapshot.docs[0]) {
            return null;
        }

        const docRef = snapshot.docs[0].ref;
        const currentData = snapshot.docs[0].data() as UserProfile;

        if (currentData.role === 'elder') {
            const elderUpdate = updatedData as Partial<ElderProfile>;

            if (elderUpdate.foodTime) {
                const { breakfast, lunch, dinner } = elderUpdate.foodTime;
                if (!breakfast || !lunch || !dinner) {
                    throw new Error('foodTime must include breakfast, lunch, and dinner');
                }
            }

            if (elderUpdate.ncdConditions) {
                const validDiseases: NCDisease[] = ['diabetes', 'hypertension'];
                const isValid = elderUpdate.ncdConditions.every(d => validDiseases.includes(d));
                if (!isValid) {
                    throw new Error('Invalid ncdConditions value');
                }
            }
        }

        const { uid: _, createdAt, ...safeUpdate } = updatedData as any;
        await docRef.update({
            ...safeUpdate,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        const updatedSnapshot = await docRef.get();
        return updatedSnapshot.data() as UserProfile;
    } catch (error) {
        throw new Error(`Failed to update user profile: ${error}`);
    }
};

//   ใหม่: ค้นหา user จากเบอร์โทร
export const getUserByPhone = async (phone: string): Promise<UserProfile | null> => {
    const snapshot = await usersCollection
        .where('phoneNumber', '==', phone)
        .limit(1)
        .get();

    if (snapshot.empty) return null;

    const doc = snapshot.docs[0];
    return doc ? (doc.data() as UserProfile) : null;
};
