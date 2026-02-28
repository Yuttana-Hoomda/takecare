import { db } from "../config/firebase.js";
import type { Task } from "../models/taskModel.js";
import { FieldValue } from 'firebase-admin/firestore'; 

const tasksCollection = db.collection('tasks');

export const createTask = async (taskData: Omit<Task, 'id' | 'createdAt'>) => {
    const docRef = tasksCollection.doc(); 

    const newTaskPayload = {  
        ...taskData,
        id: docRef.id,
        createdAt: new Date().toISOString(),
    };

    await docRef.set(newTaskPayload);

    return newTaskPayload;
}

export const getTasksForFamily = async (familyId: string) => {
    const snapshot = await tasksCollection.where('familyId', '==', familyId).get();

    if (snapshot.empty) {
        return [];
    }

    return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
    }));
}

export const updateTask = async (taskId: string, updatedData: Partial<Task>) => {
   
    const docRef = tasksCollection.doc(taskId);
    await docRef.update(updatedData);

    
    const updatedDoc = await docRef.get();
    return {
        id: updatedDoc.id,
        ...updatedDoc.data()
    };
}


export const deleteTask = async (taskId: string): Promise<void> => {
    await tasksCollection.doc(taskId).delete();
}