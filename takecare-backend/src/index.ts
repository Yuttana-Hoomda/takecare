import express, { type Application } from 'express';
import userRoutes from './routes/userRoutes.js';
import familyRoutes from './routes/familyRoutes.js';
import taskRoutes from './routes/taskRoutes.js';

const app: Application = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Mount the user routes
app.use('/api/users', userRoutes);
app.use('/api', familyRoutes);
app.use('/api', taskRoutes);

app.listen(port, () => {
    console.log(`🚀 Backend server running at http://localhost:${port}`);
});