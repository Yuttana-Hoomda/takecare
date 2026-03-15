class AutomatedAlarmModel {
  final String id;
  final String title;
  final String scheduledTime;
  final String? notes;

  const AutomatedAlarmModel({
    required this.id,
    required this.title,
    required this.scheduledTime,
    this.notes,
  });
}
