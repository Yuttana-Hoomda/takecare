import express, { type Application } from 'express';
import cors from 'cors'; // 1. import cors เข้ามา
import userRoutes from './routes/userRoutes.js';
import familyRoutes from './routes/familyRoutes.js';
import taskRoutes from './routes/taskRoutes.js';
import foodAnalysisRoutes from './routes/foodAnalysisRoutes.js';
import { GoogleGenerativeAI } from '@google/generative-ai';
import devRoutes from "./routes/dev.routes.js";
import eventRoutes from './routes/eventRoutes.js';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);
const app: Application = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '5mb' }));

// Mount the user routes
app.use('/api/users', userRoutes);
app.use('/api', familyRoutes);
app.use('/api', taskRoutes);
app.use('/api/food-analysis', foodAnalysisRoutes);
app.use('/api', eventRoutes);


// Add this inside your index.ts where you define your routes

app.get('/api/models', async (req, res) => {
    try {
        const apiKey = process.env.GEMINI_API_KEY;

        if (!apiKey) {
            throw new Error("API_KEY is not defined in the environment variables.");
        }

        // Hit the Gemini REST API directly to get the models
        const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`);
        const data = await response.json();

        // Check if Google returned an error (like an invalid key)
        if (!response.ok) {
            throw new Error(data.error?.message || "Failed to fetch from Google API");
        }

        // Map through the raw response to extract just the names
        const modelNames = data.models.map((m: { name: string }) => m.name);

        res.status(200).json({
            success: true,
            models: modelNames
        });

    } catch (error) {
        console.error("Error fetching models:", error);

        // Type guard for TypeScript
        const errorMessage = error instanceof Error ? error.message : "An unknown error occurred";

        res.status(500).json({
            success: false,
            message: "Failed to fetch models",
            error: errorMessage
        });
    }
});

// test dev route
app.use("/api/dev", devRoutes);

app.listen(port, () => {
    console.log(`🚀 Backend server running at http://localhost:${port}`);
});