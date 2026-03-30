import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../config/firebase.js';

const familiesCollection = db.collection('family'); //   ตรงกับ Firestore จริง
const usersCollection = db.collection('users');

// สร้าง family ใหม่ พร้อม link ทั้ง elder และ caregiver
export const createFamily = async (elderId: string, caregiverId: string) => {
    const batch = db.batch();

    const newFamilyRef = familiesCollection.doc();

    const elderSnapshot = await usersCollection.where('uid', '==', elderId).get();
    const caregiverSnapshot = await usersCollection.where('uid', '==', caregiverId).get();

    //   field ชื่อตรงกับ Firestore จริง: elder / caregiver (array)
    const newFamily = {
        familyId: newFamilyRef.id,
        elder: elderId,
        caregiver: [caregiverId],
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
};

// เพิ่ม caregiver เข้า family ที่มีอยู่แล้ว
export const addCaregiverToExistingFamily = async (familyId: string, caregiverId: string) => {
    const batch = db.batch();

    const familyRef = familiesCollection.doc(familyId);
    const caregiverSnapshot = await usersCollection.where('uid', '==', caregiverId).get();

    batch.update(familyRef, {
        caregiver: FieldValue.arrayUnion(caregiverId),
    });

    if (caregiverSnapshot.docs[0]) {
        batch.update(caregiverSnapshot.docs[0].ref, { familyId });
    }

    await batch.commit();
};

//   caregiver กรอกเบอร์ elder → ระบบ link ให้อัตโนมัติ
// - ถ้า elder ยังไม่มี family → สร้าง family ใหม่ แล้ว link
// - ถ้า elder มี family อยู่แล้ว → เพิ่ม caregiver เข้าไป
export const linkCaregiverByElderUid = async (
    elderUid: string,
    caregiverUid: string
): Promise<void> => {
    // ดึงข้อมูล elder จาก users collection
    const elderSnapshot = await usersCollection.where('uid', '==', elderUid).limit(1).get();
    if (elderSnapshot.empty) {
        throw new Error('Elder not found');
    }

    const elderData = elderSnapshot.docs[0]!.data();
    const existingFamilyId = elderData['familyId'] as string | undefined;

    if (existingFamilyId) {
        // Elder มี family อยู่แล้ว → แค่เพิ่ม caregiver array union
        await addCaregiverToExistingFamily(existingFamilyId, caregiverUid);
    } else {
        // Elder ยังไม่มี family → สร้างใหม่
        await createFamily(elderUid, caregiverUid);
    }
};
// ดึงข้อมูล elder จาก familyId สำหรับ caregiver home
export const getElderInfoByFamilyId = async (familyId: string) => {
  const familySnapshot = await familiesCollection.doc(familyId).get();
  if (!familySnapshot.exists) throw new Error('Family not found');

  const family = familySnapshot.data();
  const elderId = family?.['elder'] as string | undefined;
  if (!elderId) throw new Error('Elder not found in family');

  const elderSnapshot = await usersCollection
    .where('uid', '==', elderId)
    .limit(1)
    .get();

  if (elderSnapshot.empty) throw new Error('Elder user not found');

  const elder = elderSnapshot.docs[0].data();
  return {
    uid:          elder['uid']          ?? '',
    displayName:  elder['displayName']  ?? 'ผู้สูงอายุ',
    phoneNumber:  elder['phoneNumber']  ?? '',
    profileImgUrl: elder['profileImgUrl'] ?? '',
  };
};

// version ที่ดีกว่า: ดึงข้อมูล elder แบบ efficient
// รองรับกรณีที่ document ID ไม่ตรงกับ familyId field
export const getElderInfoByFamilyIdSafe = async (familyId: string) => {
  // ลอง doc(familyId) ก่อน
  let familyDoc = await familiesCollection.doc(familyId).get();

  // ถ้าไม่เจอ ลอง query
  if (!familyDoc.exists) {
    const snap = await familiesCollection
      .where('familyId', '==', familyId)
      .limit(1)
      .get();
    if (snap.empty) throw new Error('Family not found');
    familyDoc = snap.docs[0];
  }

  const family = familyDoc.data();
  const elderId = family?.['elder'] as string | undefined;
  if (!elderId) throw new Error('Elder not found in family');

  const elderSnapshot = await usersCollection
    .where('uid', '==', elderId)
    .limit(1)
    .get();

  if (elderSnapshot.empty) throw new Error('Elder user not found');

  const elder = elderSnapshot.docs[0].data();
  return {
    uid:           elder['uid']          ?? '',
    displayName:   elder['displayName']  ?? 'ผู้สูงอายุ',
    phoneNumber:   elder['phoneNumber']  ?? '',
    profileImgUrl: elder['profileImgUrl'] ?? '',
  };
};
