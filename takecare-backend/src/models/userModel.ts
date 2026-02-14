import * as admin from 'firebase-admin';

export type UserRole = 'elderly' | 'caregiver';
export type NCDisease = 'diabetes' | 'hypertension' | 'kidney' | null;

export interface UserProfile {
    uid: string;   
    displayName: string;
    phoneNumber: string;
    profileImgUrl: string;
    role: UserRole;
    familyId?: string;   
    ncdConditions?: NCDisease[];
    createdAt: admin.firestore.Timestamp;
}

export type CreateUserDTO = Omit<UserProfile, 'createdAt'>;