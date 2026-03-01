// lib/features/medication_alarm_overlay/models/medication_alarm_model.dart

class MedicationAlarmModel {
  final String id;
  final String medicationName;
  final String scheduledTime;
  final String? dosage;
  final String? notes;

  const MedicationAlarmModel({
    required this.id,
    required this.medicationName,
    required this.scheduledTime,
    this.dosage,
    this.notes,
  });
}
