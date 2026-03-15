class AiAnalysisResult {
  final String healthLevel;
  final double sugar;
  final double sodium;
  final String analysisResult;

  const AiAnalysisResult({
    required this.healthLevel,
    required this.sugar,
    required this.sodium,
    required this.analysisResult
  });

  factory AiAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AiAnalysisResult(
      healthLevel: json['healthLevel'] ?? '',
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0.0,
      analysisResult: json['analysisResult'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'healthLevel': healthLevel,
    'sugar': sugar,
    'sodium': sodium,
    'analysisResult': analysisResult,
  };
}