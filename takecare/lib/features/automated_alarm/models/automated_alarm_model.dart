class AutomatedAlarmModel {
  final String id;
  final String title;
  final String scheduledTime;
  final String? notes;
  final String elderlyId;
  final String familyId;
  final bool requirePhoto; // ✅ [NEW] แยก alarm screen ตาม field นี้

  const AutomatedAlarmModel({
    required this.id,
    required this.title,
    required this.scheduledTime,
    required this.elderlyId,
    required this.familyId,
    this.notes,
    this.requirePhoto = false,
  });
}
