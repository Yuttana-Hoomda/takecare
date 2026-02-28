export interface NutrientData {
    foodId: string;
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
    foodName: string;
    healthLevel: 'healthy' | 'moderate' | 'unhealthy';
    sugar: number;
    sodium: number;
    fat: number;
    calories: number;
    analysisResult: string;
}

export interface SaveAnalysisRequest {
    elderlyId: string;
    familyId: string;
    imageUrl: string;
    analysisResult: AnalysisResult;
}