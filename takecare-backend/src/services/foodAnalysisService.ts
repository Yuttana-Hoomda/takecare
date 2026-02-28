import { GoogleGenerativeAI } from '@google/generative-ai';
import * as fs from 'fs';
import * as path from 'path';
import * as csv from 'csv-parse/sync';
import { db } from '../config/firebase.js';
import type { AnalysisResult, NutrientData, SaveAnalysisRequest } from '../models/foodAnalysisModel.js';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);

const calculateHealthLevel = (data: {
    calories: number;
    fat: number;
    sugar: number;
    sodium: number;
}): 'healthy' | 'moderate' | 'unhealthy' => {
    let score = 0;

    if (data.calories > 500) score += 2;
    else if (data.calories > 300) score += 1;

    if (data.fat > 20) score += 2;
    else if (data.fat > 10) score += 1;

    if (data.sugar > 15) score += 2;
    else if (data.sugar > 8) score += 1;

    if (data.sodium > 800) score += 2;
    else if (data.sodium > 400) score += 1;

    if (score >= 5) return 'unhealthy';
    if (score >= 2) return 'moderate';
    return 'healthy';
};

// ─── CSV Cache ────────────────────────────────────────────────────────────────
let nutrientsMap: Map<string, NutrientData> | null = null;

const getNutrientsMap = (): Map<string, NutrientData> => {
    if (nutrientsMap) return nutrientsMap;

    const csvPath = path.join(process.cwd(), 'src', 'data', 'Food-data.csv');
    const fileContent = fs.readFileSync(csvPath, 'utf-8');

    const records = csv.parse(fileContent, {
        columns: true,
        skip_empty_lines: true,
        relax_column_count: true,
    }) as Record<string, string>[];

    nutrientsMap = new Map<string, NutrientData>();

    for (const row of records) {
        const englishName = row['English']?.toLowerCase().trim();
        const thaiName = row['Thai']?.toLowerCase().trim();
        if (!englishName) continue;

        const entry: NutrientData = {
            foodId: row['Food ID']?.trim() || '',
            foodNameThai: row['Thai']?.trim() || '',
            foodNameEnglish: row['English']?.trim() || '',
            calories: parseFloat(row['Energy (Energy) (kcal)'] || '0') || 0,
            protein: parseFloat(row['Protein (g)'] || '0') || 0,
            fat: parseFloat(row['Fat (g)'] || '0') || 0,
            carbohydrate: parseFloat(row['Carbohydrate, avalible (Carbohydrate, total) (g)'] || '0') || 0,
            sugar: parseFloat(row['Sugar (g)'] || '0') || 0,
            sodium: parseFloat(row['Sodium (mg)'] || '0') || 0,
            cholesterol: parseFloat(row['Cholesterol (mg)'] || '0') || 0,
            dietaryFibre: parseFloat(row['Dietary fibre (Crud fibre) (g)'] || '0') || 0,
        };

        nutrientsMap.set(englishName, entry);
        if (thaiName) nutrientsMap.set(thaiName, entry);
    }

    console.log(`[NutrientsDB] Loaded ${nutrientsMap.size / 2} food entries into cache`);
    return nutrientsMap;
};

// ─── Lookup ───────────────────────────────────────────────────────────────────
const findNutrientByName = (foodName: string): NutrientData | null => {
    const map = getNutrientsMap();
    const normalized = foodName.toLowerCase().trim();

    // O(1) exact match
    if (map.has(normalized)) return map.get(normalized)!;

    // Normalize: strip spaces, commas, hyphens for comparison
    const strip = (s: string) => s.toLowerCase().replace(/[\s\-,().]/g, '');
    const strippedInput = strip(normalized);

    for (const [key, value] of map) {
        // Stripped exact match
        if (strip(key) === strippedInput) return value;

        // All input words found in key
        const inputWords = normalized.split(' ').filter(w => w.length > 2);
        if (inputWords.length > 0 && inputWords.every(w => key.includes(w))) return value;

        // All key words found in input
        const keyWords = key.split(' ').filter(w => w.length > 2);
        if (keyWords.length > 0 && keyWords.every(w => normalized.includes(w))) return value;
    }

    return null;
};

// ─── Generate 2-sentence health summary (Thai only) ──────────────────────────
const generateSummary = async (
    model: any,
    foodName: string,
    healthLevel: string
): Promise<string> => {
    // ✅ Strong Thai-only instruction
    const prompt = `คุณคือนักโภชนาการชาวไทย กรุณาเขียนสองประโยคสั้นๆ เป็นภาษาไทยเท่านั้น ห้ามใช้ภาษาอังกฤษ อธิบายผลกระทบต่อสุขภาพของการรับประทาน "${foodName}" ซึ่งถูกจัดว่า "${healthLevel}" ให้กระชับและเป็นประโยชน์`;
    const result = await model.generateContent(prompt);
    return result.response.text().trim();
};

// ─── Main Analysis Function ───────────────────────────────────────────────────
export const analyzeFood = async (base64Image: string): Promise<AnalysisResult> => {
    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

    const imagePart = {
        inlineData: { data: base64Image, mimeType: 'image/jpeg' },
    };

    // Step 1: Identify food — prompt to match CSV naming style
    const identifyPrompt = `Look at this food image and identify the main food item or dish.
Use descriptive english naming style like "Noodle, stir fried, with shrimp" or "Rice, steamed" not brand or slang names like "pad thai".
Respond with ONLY a JSON object, no markdown, no explanation:
{"foodName": "the food name in english, lowercase"}`;

    const identifyResult = await model.generateContent([identifyPrompt, imagePart]);
    const identifyText = identifyResult.response.text().trim();

    let detectedFoodName: string;
    try {
        const cleaned = identifyText.replace(/```json|```/g, '').trim();
        detectedFoodName = JSON.parse(cleaned).foodName;
    } catch {
        const match = identifyText.match(/"foodName"\s*:\s*"([^"]+)"/);
        detectedFoodName = match?.[1] ?? 'unknown food';
    }

    console.log(`[FoodAnalysis] Detected: ${detectedFoodName}`);

    // Step 2: Lookup CSV
    const nutrientData = findNutrientByName(detectedFoodName);

    if (nutrientData) {
        console.log(`[FoodAnalysis] Found in CSV: ${nutrientData.foodNameEnglish}`);

        const healthLevel = calculateHealthLevel({
            calories: nutrientData.calories,
            fat: nutrientData.fat,
            sugar: nutrientData.sugar,
            sodium: nutrientData.sodium,
        });

        // ✅ Pass Thai name to summary
        const summary = await generateSummary(
            model,
            nutrientData.foodNameThai || nutrientData.foodNameEnglish,
            healthLevel
        );

        return {
            foodName: nutrientData.foodNameThai, // ✅ Thai name from CSV
            healthLevel,
            sugar: nutrientData.sugar,
            sodium: nutrientData.sodium,
            fat: nutrientData.fat,
            calories: nutrientData.calories,
            analysisResult: summary,             // ✅ Thai summary
        };
    }

    // Step 3: Not in CSV — Gemini estimates everything in Thai
    console.log(`[FoodAnalysis] Not found in CSV, asking Gemini to estimate: ${detectedFoodName}`);

    // ✅ Force Thai in both foodNameThai and analysisResult
    const nutrientPrompt = `Based on general nutritional knowledge, provide estimated nutritional values for "${detectedFoodName}" per serving.
Respond with ONLY a JSON object in this exact format, no markdown, no explanation.
IMPORTANT: foodNameThai and analysisResult must be written in Thai language only, absolutely no English:
{
  "foodNameThai": "<ชื่ออาหารเป็นภาษาไทยเท่านั้น>",
  "sugar": <number in grams>,
  "sodium": <number in mg>,
  "fat": <number in grams>,
  "calories": <number in kcal>,
  "healthLevel": "<healthy|moderate|unhealthy>",
  "analysisResult": "<สองประโยคภาษาไทยเท่านั้น ห้ามใช้ภาษาอังกฤษ อธิบายผลกระทบต่อสุขภาพของอาหารนี้>"
}`;

    const nutrientResult = await model.generateContent(nutrientPrompt);
    const nutrientText = nutrientResult.response.text().trim();

    try {
        const cleaned = nutrientText.replace(/```json|```/g, '').trim();
        const nutrients = JSON.parse(cleaned);
        return {
            foodName: nutrients.foodNameThai || detectedFoodName,  // ✅ Thai name
            healthLevel: nutrients.healthLevel || 'moderate',
            sugar: Number(nutrients.sugar) || 0,
            sodium: Number(nutrients.sodium) || 0,
            fat: Number(nutrients.fat) || 0,
            calories: Number(nutrients.calories) || 0,
            analysisResult: nutrients.analysisResult || 'ไม่สามารถวิเคราะห์ได้', // ✅ Thai fallback
        };
    } catch {
        return {
            foodName: detectedFoodName,
            healthLevel: 'moderate',
            sugar: 0,
            sodium: 0,
            fat: 0,
            calories: 0,
            analysisResult: 'ไม่สามารถวิเคราะห์อาหารนี้ได้', // ✅ Thai fallback
        };
    }
};

// ─── Save to Firestore ────────────────────────────────────────────────────────
export const saveAnalysis = async (data: SaveAnalysisRequest): Promise<string> => {
    const docRef = await db.collection('food_analyses').add({
        elderlyId: data.elderlyId,
        familyId: data.familyId,
        imageUrl: data.imageUrl,
        foodName: data.analysisResult.foodName,
        healthLevel: data.analysisResult.healthLevel,
        sugar: data.analysisResult.sugar,
        sodium: data.analysisResult.sodium,
        fat: data.analysisResult.fat,
        calories: data.analysisResult.calories,
        analysisResult: data.analysisResult.analysisResult,
        createdAt: new Date(),
    });
    return docRef.id;
};