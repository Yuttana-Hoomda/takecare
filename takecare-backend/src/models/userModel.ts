import * as admin from 'firebase-admin';

// 1. Add 'pending' to the allowed roles
export type UserRole = 'elder' | 'caregiver' | 'pending';
export type NCDisease = 'diabetes' | 'hypertension';

export interface MealSchedule {
    breakfast: { hour: number, minute: number };
    lunch: { hour: number, minute: number };
    dinner: { hour: number, minute: number };
}

export interface BaseUserProfile {
    uid: string;
    displayName: string;
    phoneNumber: string;
    profileImgUrl: string;
    familyId?: string;
    createdAt: admin.firestore.Timestamp;
}

// 2. Create a new interface for Screen 1 users
export interface PendingProfile extends BaseUserProfile {
    role: 'pending';
}

export interface ElderProfile extends BaseUserProfile {
    role: 'elder';
    ncdConditions?: NCDisease[];
    foodTime: MealSchedule;
}

export interface CaregiverProfile extends BaseUserProfile {
    role: 'caregiver';
}

// 3. Add PendingProfile to the main UserProfile union
export type UserProfile = ElderProfile | CaregiverProfile | PendingProfile;

export type CreateElderDTO = Omit<ElderProfile, 'createdAt'>;
export type CreateCaregiverDTO = Omit<CaregiverProfile, 'createdAt'>;
// 4. Create a DTO for Pending
export type CreatePendingDTO = Omit<PendingProfile, 'createdAt'>;

// 5. Update the CreateUserDTO union
export type CreateUserDTO = CreateElderDTO | CreateCaregiverDTO | CreatePendingDTO;