import express, { type Application } from 'express';
import userRoutes from './routes/userRoutes.js';

const app: Application = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Mount the user routes
app.use('/api/users', userRoutes);

app.listen(port, () => {
    console.log(`🚀 Backend server running at http://localhost:${port}`);
});