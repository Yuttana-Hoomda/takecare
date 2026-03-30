import { GoogleGenerativeAI } from '@google/generative-ai';
import type { GenerativeModel, InlineDataPart } from '@google/generative-ai';
import * as fs from 'fs';
import * as path from 'path';
import * as csv from 'csv-parse/sync';
import { v2 as cloudinary } from 'cloudinary';
import { db } from '../config/firebase.js';
import type { AnalysisResult, NutrientData, SaveAnalysisRequest } from '../models/foodAnalysisModel.js';
import { FieldValue } from 'firebase-admin/firestore';
import type { NCDisease } from '../models/userModel.js';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME!,
    api_key: process.env.CLOUDINARY_API_KEY!,
    api_secret: process.env.CLOUDINARY_API_SECRET!,
});

export const uploadImageToCloudinary = async (base64Image: string): Promise<string> => {
    const dataUri = base64Image.startsWith('data:')
        ? base64Image
        : `data:image/jpeg;base64,${base64Image}`;

    const result = await cloudinary.uploader.upload(dataUri, {
        folder: 'food_analyses',
        resource_type: 'image',
    });

    return result.secure_url;
};

type Diseases = NCDisease[] | null | undefined;
type HealthLevel = 'healthy' | 'moderate' | 'unhealthy';

// fix #6: map health level to Thai for prompts
const HEALTH_LEVEL_THAI: Record<HealthLevel, string> = {
    healthy: 'ดีต่อสุขภาพ',
    moderate: 'พอรับได้',
    unhealthy: 'ไม่ดีต่อสุขภาพ',
};

interface NutritionThreshold {
    calories: { moderate: number; unhealthy: number };
    fat: { moderate: number; unhealthy: number };
    sugar: { moderate: number; unhealthy: number };
    sodium: { moderate: number; unhealthy: number };
}

// เกณฑ์ต่อมื้อ (≈ 1/3 ของปริมาณต่อวัน) อ้างอิงกระทรวงสาธารณสุขไทย
const THRESHOLDS: Record<'none' | 'diabetes' | 'hypertension', NutritionThreshold> = {
    none: {
        calories: { moderate: 667, unhealthy: 933 },
        fat: { moderate: 22, unhealthy: 30 },
        sugar: { moderate: 8, unhealthy: 17 },
        sodium: { moderate: 667, unhealthy: 1067 },
    },
    diabetes: {
        calories: { moderate: 533, unhealthy: 800 },
        fat: { moderate: 18, unhealthy: 25 },
        sugar: { moderate: 5, unhealthy: 10 },
        sodium: { moderate: 667, unhealthy: 1067 },
    },
    hypertension: {
        calories: { moderate: 667, unhealthy: 933 },
        fat: { moderate: 22, unhealthy: 30 },
        sugar: { moderate: 8, unhealthy: 17 },
        sodium: { moderate: 500, unhealthy: 800 },
    },
};

const getThresholdKey = (disease: Diseases): 'none' | 'diabetes' | 'hypertension' => {
    if (!disease || disease.length === 0) return 'none';
    if (disease.includes('diabetes')) return 'diabetes';
    if (disease.includes('hypertension')) return 'hypertension';
    return 'none';
};

const calculateHealthLevel = (data: {
    calories: number;
    fat: number;
    sugar: number;
    sodium: number;
    disease: Diseases;
}): HealthLevel => {
    const t = THRESHOLDS[getThresholdKey(data.disease)];
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

    if (score >= 4) return 'unhealthy';
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

    let entryCount = 0;

    for (const row of records) {
        const englishName = row['English']?.toLowerCase().trim();
        const thaiName = row['Thai']?.toLowerCase().trim();
        if (!englishName) continue;

        const entry: NutrientData = {
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
        entryCount++;
        if (thaiName) nutrientsMap.set(thaiName, entry);
    }

    console.log(`[NutrientsDB] Loaded ${entryCount} food entries into cache`);
    return nutrientsMap;
};

// ─── Lookup ───────────────────────────────────────────────────────────────────
const findNutrientByName = (foodName: string): NutrientData | null => {
    const map = getNutrientsMap();
    const normalized = foodName.toLowerCase().trim();

    // 1. Exact match
    if (map.has(normalized)) return map.get(normalized)!;

    const strip = (s: string) => s.toLowerCase().replace(/[\s\-,().]/g, '');
    const strippedInput = strip(normalized);

    // 2. Stripped exact match
    for (const [key, value] of map) {
        if (strip(key) === strippedInput) return value;
    }

    // 3. All KEY words found in input (key drives the match, not input)
    // Require key to have multiple meaningful words to avoid short/generic matches
    for (const [key, value] of map) {
        const keyWords = key.split(' ').filter(w => w.length > 3); // stricter: >3 not >2
        if (keyWords.length >= 2 && keyWords.every(w => normalized.includes(w))) return value;
    }

    // 4. Input words match — only if MOST input words match the key (>= 60%)
    for (const [key, value] of map) {
        const inputWords = normalized.split(' ').filter(w => w.length > 3);
        if (inputWords.length === 0) continue;

        const matchCount = inputWords.filter(w => key.includes(w)).length;
        const matchRatio = matchCount / inputWords.length;

        if (matchRatio >= 0.6) return value;
    }

    return null;
};

// ─── Generate health summary (Thai only) ─────────────────────────────────────
const generateSummary = async (
    model: GenerativeModel,
    detectedName: string,       // full dish name from image
    csvFoodName: string,        // matched CSV entry name
    healthLevel: HealthLevel
): Promise<string> => {
    const healthLevelThai = HEALTH_LEVEL_THAI[healthLevel];
    const prompt = `คุณคือนักโภชนาการชาวไทย กรุณาเขียนหนึ่งประโยคสั้นๆ เป็นภาษาไทยเท่านั้น ห้ามใช้ภาษาอังกฤษ 
อาหารที่ตรวจพบคือ "${detectedName}" (ส่วนประกอบหลักจากฐานข้อมูล: "${csvFoodName}") 
ถูกจัดว่า "${healthLevelThai}" อธิบายผลกระทบต่อสุขภาพให้กระชับและเป็นประโยชน์`;

    const result = await model.generateContent(prompt);
    return result.response.text().trim();
};

// ─── Main Analysis Function ───────────────────────────────────────────────────
export const analyzeFood = async (base64Image: string, disease: Diseases | undefined): Promise<AnalysisResult> => {
    const raw = base64Image.includes(',') ? base64Image.split(',')[1] : base64Image;

    // ✅ guard: ensure base64Data is a defined string
    if (!raw) {
        throw new Error('Invalid image data: base64 string is empty');
    }

    const base64Data: string = raw; // now narrowed to string, not string | undefined

    // size guard (~10MB)
    if (base64Data.length > 10 * 1024 * 1024 * (4 / 3)) {
        throw new Error('Image too large. Please use an image under 10MB.');
    }

    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

    const mimeType = base64Image.startsWith('data:image/png') ? 'image/png' : 'image/jpeg';

    // ✅ explicitly typed as InlineDataPart to satisfy the union
    const imagePart: InlineDataPart = {
        inlineData: { data: base64Data, mimeType },
    };

    // Step 1: Identify food
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
            disease,
        });

        const summary = await generateSummary(
            model,
            detectedFoodName,  // use the actual detected dish name as primary
            nutrientData.foodNameThai || nutrientData.foodNameEnglish,
            healthLevel
        );

        const thresholds = THRESHOLDS[getThresholdKey(disease)];
        return {
            healthLevel,
            sugar: nutrientData.sugar,
            sodium: nutrientData.sodium,
            analysisResult: summary,
        };
    }

    console.log(`[FoodAnalysis] Not found in CSV, asking Gemini to estimate: ${detectedFoodName}`);

    // fix #8: pass disease context to Gemini for correct health scoring
    const diseaseContext = disease
        ? `ผู้ใช้มีโรค${disease} กรุณาปรับระดับสุขภาพให้เหมาะสมกับโรคนี้`
        : '';

    const nutrientPrompt = `Based on general nutritional knowledge, provide estimated nutritional values for "${detectedFoodName}" per serving.
${diseaseContext}
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
            healthLevel: nutrients.healthLevel || 'moderate',
            sugar: Number(nutrients.sugar) || 0,
            sodium: Number(nutrients.sodium) || 0,
            analysisResult: nutrients.analysisResult || 'ไม่สามารถวิเคราะห์ได้',
        };
    } catch {
        return {
            healthLevel: 'moderate',
            sugar: 0,
            sodium: 0,
            analysisResult: 'ไม่สามารถวิเคราะห์อาหารนี้ได้',
        };
    }
};

// ─── Save to Firestore ────────────────────────────────────────────────────────
export const saveAnalysis = async (data: SaveAnalysisRequest, displayTitle: string): Promise<{ foodId: string, eventId: string }> => {
    console.log('[Cloudinary] Uploading image...');
    const imageUrl = await uploadImageToCloudinary(data.imageBase64);
    console.log('[Cloudinary] Upload success:', imageUrl)

    const dateString = new Date().toISOString().slice(0, 10);
    
    const foodDocRef = await db.collection('food_analyses').add({
        elderlyId: data.elderlyId,
        familyId: data.familyId,
        imageUrl: imageUrl,
        healthLevel: data.analysisResult.healthLevel,
        sugar: data.analysisResult.sugar,
        sodium: data.analysisResult.sodium,
        analysisResult: data.analysisResult.analysisResult,
    });


    const eventDocRef = await db.collection('events').add({
        date: new Date().toISOString().slice(0, 10),
        elderlyId: data.elderlyId,
        familyId: data.familyId,
        referenceId: foodDocRef.id,       
        type: 'foodAnalysis',
        referenceCollection: 'food_analyses',
        displayTitle, 
        displaySubtitle: data.analysisResult.analysisResult,
        thumbnailUrl: imageUrl,
        status: 'completed',
        createdAt: FieldValue.serverTimestamp(),
    });

    // 3. Update the Event Calendar Summary
    const calendarDocId = `${data.elderlyId}_${dateString}`;
    const calendarRef = db.collection('event_calendar').doc(calendarDocId);
    const calendarSnap = await calendarRef.get();

    if (!calendarSnap.exists) {
        await calendarRef.set({
            date: dateString,
            elderlyId: data.elderlyId,
            familyId: data.familyId,
            completedCount: 1,
            totalCount: 1,
            createdAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
        });
    } else {
        await calendarRef.update({
            completedCount: FieldValue.increment(1),
            totalCount: FieldValue.increment(1),
            updatedAt: FieldValue.serverTimestamp(),
        });
    }

    return { foodId: foodDocRef.id, eventId: eventDocRef.id };
};

export const getFoodAnalysisById = async (foodId: string) => {
    const doc = await db.collection('food_analyses').doc(foodId).get();

    if (!doc.exists) return null;

    return {
        foodId: doc.id,
        ...doc.data(),
    };
};
