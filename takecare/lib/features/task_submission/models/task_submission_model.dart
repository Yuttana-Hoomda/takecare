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
    DateTime parsedDate;
    
    // จัดการกับ createdAt ที่อาจมาเป็น String หรือ Map (Firestore Timestamp)
    var createdAtData = json['createdAt'];
    
    if (createdAtData is String) {
      parsedDate = DateTime.parse(createdAtData);
    } else if (createdAtData is Map && createdAtData.containsKey('_seconds')) {
      // กรณีมาเป็น { _seconds: ..., _nanoseconds: ... } จาก Firestore
      int seconds = createdAtData['_seconds'] as int;
      parsedDate = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    } else {
      parsedDate = DateTime.now();
    }

    return TaskSubmission(
      id: json['id'] as String? ?? '',
      taskId: json['taskId'] as String? ?? '',
      elderlyId: json['elderlyId'] as String? ?? '',
      familyId: json['familyId'] as String? ?? '',
      proofImgUrl: json['proofImgUrl'] as String?,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    'elderlyId': elderlyId,
    'familyId': familyId,
    'proofImgUrl': proofImgUrl,
  };
}
