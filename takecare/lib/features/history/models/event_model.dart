/// รายการ event ของวันที่เลือก
class Event {
  final String date;
  final String elderlyId;
  final String familyId;
  final String type;                // "task" | "foodAnalysis"
  final String referenceCollection; // "task_submission" | "food_analyses"
  final String referenceId;
  final String displayTitle;
  final String? displaySubtitle;
  final String? thumbnailUrl;
  final String icon;
  final String status;              // "completed" | "missed"
  final DateTime createdAt;

  const Event({
    required this.date,
    required this.elderlyId,
    required this.familyId,
    required this.type,
    required this.referenceCollection,
    required this.referenceId,
    required this.displayTitle,
    this.displaySubtitle,
    this.thumbnailUrl,
    required this.icon,
    required this.status,
    required this.createdAt,
  });

  bool get isCompleted => status == 'completed';
  bool get isFoodAnalysis => type == 'foodAnalysis'; // ← ตรงกับ backend แล้ว

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      date: json['date'] as String,
      elderlyId: json['elderlyId'] as String,
      familyId: json['familyId'] as String,
      type: json['type'] as String,
      referenceCollection: json['referenceCollection'] as String,
      referenceId: json['referenceId'] as String,
      displayTitle: json['displayTitle'] as String,
      displaySubtitle: json['displaySubtitle'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      icon: json['icon'] as String? ?? 'assets/task.svg',
      status: json['status'] as String,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : DateTime.fromMillisecondsSinceEpoch(
          (json['createdAt']?['_seconds'] as int? ?? 0) * 1000),
    );
  }
}