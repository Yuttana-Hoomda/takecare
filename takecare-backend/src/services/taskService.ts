import { db } from "../config/firebase.js";
import type { Task } from "../models/taskModel.js";
import { FieldValue } from 'firebase-admin/firestore'; 

const tasksCollection = db.collection('tasks');

export const createTask = async (taskData: Omit<Task, 'id' | 'createdAt'>) => {

    const newTaskPayload = {
        ...taskData,
        createdAt: FieldValue.serverTimestamp(),
    };

    const docRef = await tasksCollection.add(newTaskPayload);

    return {
        id: docRef.id,
        ...newTaskPayload
    };
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
   
    const taskRef = tasksCollection.doc(taskId);

    await taskRef.update(updatedData);

    return {
        id: taskId,
        ...updatedData
    };
}


export const deleteTask = async (taskId: string): Promise<void> => {
    await tasksCollection.doc(taskId).delete();
}