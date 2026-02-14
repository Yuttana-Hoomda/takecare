import * as admin from 'firebase-admin';

export interface Family {
    familyId: string;                     
    elderlyId: string;                   
    caregiverIds: string[];              
    createdAt: admin.firestore.Timestamp;
}