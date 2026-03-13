import 'package:takecare/features/food_alarm/models/ai_analysis_result_model.dart';

class SaveAnalysisFood {
  final String elderlyId;
  final String familyId;
  final String imageBase64; // ← String not File
  final AiAnalysisResult analysisResult;
  final String displayTitle;

  SaveAnalysisFood({
    required this.elderlyId,
    required this.familyId,
    required this.imageBase64,
    required this.analysisResult,
    required this.displayTitle,
  });

  Map<String, dynamic> toJson() =>
      {
        'elderlyId': elderlyId,
        'familyId': familyId,
        'imageBase64': imageBase64,
        'analysisResult': analysisResult.toJson(),
        'displayTitle': displayTitle,
      };
}