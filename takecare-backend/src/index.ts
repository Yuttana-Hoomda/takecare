import express, { type Application } from 'express';
import cors from 'cors'; // 1. import cors เข้ามา
import userRoutes from './routes/userRoutes.js';
import familyRoutes from './routes/familyRoutes.js';
import taskRoutes from './routes/taskRoutes.js';
import devRoutes from "./routes/dev.routes.js";

const app: Application = express();
const port = process.env.PORT || 3000;

app.use(cors()); // 2. เปิดใช้งาน CORS (สำคัญมาก: ต้องวางก่อน routes)
app.use(express.json());

// Mount the user routes
app.use('/api/users', userRoutes);
app.use('/api', familyRoutes);
app.use('/api', taskRoutes);

// test dev route
app.use("/api/dev", devRoutes);

app.listen(port, () => {
    console.log(`🚀 Backend server running at http://localhost:${port}`);
});