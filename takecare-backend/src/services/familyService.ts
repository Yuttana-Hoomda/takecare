import { FieldValue } from "firebase-admin/firestore";
import { db } from "../config/firebase.js";
import type { Family } from "../models/familyModel.js";

const familyCollection = db.collection('family');

export const createFamily = async (elderId: string, caregiverId: string) => {
    const batch = db.batch();

    const newFamilyRef = familyCollection.doc();
    const elderSnapshot = await db.collection('users')
        .where('uid', '==', elderId).get();
    const caregiverSnapshot = await db.collection('users')
        .where('uid', '==', caregiverId).get();

    const newFamily = {
        familyId: newFamilyRef.id,
        elderId: elderId,
        caregiverId: [caregiverId],
    };
    batch.set(newFamilyRef, newFamily);

    if (elderSnapshot.docs[0]) {
        batch.update(elderSnapshot.docs[0].ref, { familyId: newFamilyRef.id });
    }
    if (caregiverSnapshot.docs[0]) {
        batch.update(caregiverSnapshot.docs[0].ref, { familyId: newFamilyRef.id });
    }

    await batch.commit();
    return newFamily;
}

export const addCaregiver = async (familyId: string, caregiverId: string) => {
    const batch = db.batch();

    const familyRef = db.collection('families').doc(familyId);
    const caregiverRef = db.collection('users').doc(caregiverId);

    batch.update(familyRef, {
        caregiverIds: FieldValue.arrayUnion(caregiverId)
    });

    batch.update(caregiverRef, {
        familyId: familyId
    });

    try {
        await batch.commit();
        return true;
    } catch (error) {
        console.error(`Service Error: Failed to add caregiver ${caregiverId} to family ${familyId}`, error);
        throw error;
    }
}