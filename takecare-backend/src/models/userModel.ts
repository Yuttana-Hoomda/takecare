import * as admin from 'firebase-admin';

export type UserRole = 'elder' | 'caregiver';
export type NCDisease = 'diabetes' | 'hypertension';

export interface MealSchedule {
    breakfast: {
        hour: number,
        minute: number
    }; 
    lunch: {
        hour: number,
        minute: number
    };     
    dinner: {
        hour: number,
        minute: number
    };    
}

export interface BaseUserProfile {
    uid: string;
    displayName: string;
    phoneNumber: string;
    profileImgUrl: string;
    familyId?: string; 
    createdAt: admin.firestore.Timestamp;
}

export interface ElderProfile extends BaseUserProfile {
    role: 'elder';               
    ncdConditions?: NCDisease[];
    foodTime: MealSchedule;
}

export interface CaregiverProfile extends BaseUserProfile {
    role: 'caregiver';           
}

export type UserProfile = ElderProfile | CaregiverProfile;

export type CreateElderDTO = Omit<ElderProfile, 'createdAt'>;
export type CreateCaregiverDTO = Omit<CaregiverProfile, 'createdAt'>;
export type CreateUserDTO = CreateElderDTO | CreateCaregiverDTO;