import { GoogleGenerativeAI } from '@google/generative-ai';
import * as fs from 'fs';
import * as path from 'path';
import * as csv from 'csv-parse/sync';
import { db } from '../config/firebase.js';
import type { AnalysisResult, NutrientData, SaveAnalysisRequest } from '../models/foodAnalysisModel.js';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);

type Disease = 'เบาหวาน' | 'ความดัน' | null;
type HealthLevel = 'healthy' | 'moderate' | 'unhealthy';

interface NutritionThreshold {
    calories: { moderate: number; unhealthy: number };
    fat: { moderate: number; unhealthy: number };
    sugar: { moderate: number; unhealthy: number };
    sodium: { moderate: number; unhealthy: number };
}

// เกณฑ์ต่อมื้อ (≈ 1/3 ของปริมาณต่อวัน) อ้างอิงกระทรวงสาธารณสุขไทย
const THRESHOLDS: Record<NonNullable<Disease> | 'none', NutritionThreshold> = {
    none: {
        calories: { moderate: 667, unhealthy: 933 }, // วัน: 2000 kcal ÷ 3
        fat: { moderate: 22, unhealthy: 30 }, // วัน: 65g ÷ 3
        sugar: { moderate: 8, unhealthy: 17 }, // วัน: 25g ÷ 3
        sodium: { moderate: 667, unhealthy: 1067 }, // วัน: 2000mg ÷ 3
    },
    เบาหวาน: {
        calories: { moderate: 533, unhealthy: 800 }, // วัน: 1600 kcal ÷ 3
        fat: { moderate: 18, unhealthy: 25 }, // วัน: 53g ÷ 3
        sugar: { moderate: 5, unhealthy: 10 }, // วัน: 15g ÷ 3 (เบาหวานจำกัด 15g/วัน)
        sodium: { moderate: 667, unhealthy: 1067 }, // วัน: 2000mg ÷ 3
    },
    ความดัน: {
        calories: { moderate: 667, unhealthy: 933 }, // วัน: 2000 kcal ÷ 3
        fat: { moderate: 22, unhealthy: 30 }, // วัน: 65g ÷ 3
        sugar: { moderate: 8, unhealthy: 17 }, // วัน: 25g ÷ 3
        sodium: { moderate: 500, unhealthy: 800 }, // วัน: 1500mg ÷ 3 (ความดันจำกัด 1500mg/วัน)
    },
};

const calculateHealthLevel = (data: {
    calories: number;
    fat: number;
    sugar: number;
    sodium: number;
    disease: Disease;
}): HealthLevel => {
    const key = data.disease ?? 'none';
    const t = THRESHOLDS[key];

    let score = 0;

    const evaluate = (value: number, threshold: { moderate: number; unhealthy: number }) => {
        if (value > threshold.unhealthy) return 2;
        if (value > threshold.moderate) return 1;
        return 0;
    };

    score += evaluate(data.calories, t.calories);
    score += evaluate(data.fat, t.fat);
    score += evaluate(data.sugar, t.sugar);
    score += evaluate(data.sodium, t.sodium);

    // โรคเบาหวาน/ความดัน → เกณฑ์ตัดสินเข้มขึ้น 1 ระดับ
    const moderateThreshold = data.disease ? 1 : 2;
    const unhealthyThreshold = data.disease ? 4 : 5;

    if (score >= unhealthyThreshold) return 'unhealthy';
    if (score >= moderateThreshold) return 'moderate';
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
    const prompt = `คุณคือนักโภชนาการชาวไทย กรุณาเขียนหนึ่งประโยคสั้นๆ เป็นภาษาไทยเท่านั้น ห้ามใช้ภาษาอังกฤษ อธิบายผลกระทบต่อสุขภาพของการรับประทาน "${foodName}" ซึ่งถูกจัดว่า "${healthLevel}" ให้กระชับและเป็นประโยชน์`;
    const result = await model.generateContent(prompt);
    return result.response.text().trim();
};

// ─── Main Analysis Function ───────────────────────────────────────────────────
export const analyzeFood = async (base64Image: string, disease: Disease): Promise<AnalysisResult> => {
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
            disease: disease
        });

        // ✅ Pass Thai name to summary
        const summary = await generateSummary(
            model,
            nutrientData.foodNameThai || nutrientData.foodNameEnglish,
            healthLevel
        );

        return {
            foodName: nutrientData.foodNameThai, 
            healthLevel,
            sugar: nutrientData.sugar,
            sodium: nutrientData.sodium,
            fat: nutrientData.fat,
            calories: nutrientData.calories,
            analysisResult: summary,            
        };
    }

    console.log(`[FoodAnalysis] Not found in CSV, asking Gemini to estimate: ${detectedFoodName}`);

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
  "analysisResult": "<หนึ่งประโยคภาษาไทยเท่านั้น ห้ามใช้ภาษาอังกฤษ อธิบายผลกระทบต่อสุขภาพของอาหารนี้>"
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