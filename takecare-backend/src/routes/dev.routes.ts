import { Router } from "express";
import { createUserDev } from "../controllers/dev.controller.js";

const router = Router();

router.post("/create-user", createUserDev);

export default router;