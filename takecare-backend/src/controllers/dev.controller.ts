import type { Request, Response } from "express";
import { db } from "../config/firebase.js";

export const createUserDev = async (req: Request, res: Response) => {
  if (process.env.ENABLE_DEV_SEED !== "true") {
    return res.status(403).json({ error: "Not allowed" });
  }

  try {
    const {
      uid,
      displayName,
      phoneNumber,
      role,
      familyId,
      disease,
      profileImgUrl,
    } = req.body;

    if (!uid) {
      return res.status(400).json({ error: "UID is required" });
    }

    await db.collection("users").doc(uid).set({
      uid,
      displayName,
      phoneNumber,
      role,
      familyId,
      disease: disease || null,
      profileImgUrl:
        profileImgUrl || "https://i.pravatar.cc/150?img=47",
      createdAt: new Date(),
    });

    return res.json({ message: "User created successfully" });
  } catch (err: any) {
    return res.status(500).json({ error: err.message });
  }
};