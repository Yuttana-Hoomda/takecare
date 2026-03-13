export interface NutrientData {
    foodNameThai: string;
    foodNameEnglish: string;
    calories: number;
    protein: number;
    fat: number;
    carbohydrate: number;
    sugar: number;
    sodium: number;
    cholesterol: number;
    dietaryFibre: number;
}

export interface AnalysisResult {
    healthLevel: 'healthy' | 'moderate' | 'unhealthy';
    sugar: number;
    sodium: number;
    analysisResult: string;
}

export interface SaveAnalysisRequest {
    elderlyId: string;
    familyId: string;
    imageBase64: string;
    analysisResult: AnalysisResult;
}