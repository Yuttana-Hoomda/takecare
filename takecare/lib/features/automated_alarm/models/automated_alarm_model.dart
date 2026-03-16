class AutomatedAlarmModel {
  final String id;
  final String title;
  final String scheduledTime;
  final String? notes;
  final String elderlyId;  // ✅ เพิ่ม
  final String familyId;   // ✅ เพิ่ม

  const AutomatedAlarmModel({
    required this.id,
    required this.title,
    required this.scheduledTime,
    required this.elderlyId,
    required this.familyId,
    this.notes,
  });
}
