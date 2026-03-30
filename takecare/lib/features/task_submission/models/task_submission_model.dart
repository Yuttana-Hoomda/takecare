class TaskSubmission {
  final String id;
  final String taskId;
  final String elderlyId;
  final String familyId;
  final String? proofImgUrl;
  final DateTime createdAt;

  const TaskSubmission({
    required this.id,
    required this.taskId,
    required this.elderlyId,
    required this.familyId,
    this.proofImgUrl,
    required this.createdAt,
  });

  factory TaskSubmission.fromJson(Map<String, dynamic> json) {
    return TaskSubmission(
      id: json['id'] as String? ?? '',           // ✅ null safe
      taskId: json['taskId'] as String? ?? '',
      elderlyId: json['elderlyId'] as String? ?? '',
      familyId: json['familyId'] as String? ?? '',
      proofImgUrl: json['proofImgUrl'] as String?, // already nullable
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),                        // ✅ fallback if null
    );
  }

  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    'elderlyId': elderlyId,
    'familyId': familyId,
    'proofImgUrl': proofImgUrl,
  };
}