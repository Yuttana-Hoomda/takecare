enum DayStatus { complete, partial, missed }

/// ข้อมูลสรุปของแต่ละวัน — ใช้แสดง dot ใน calendar
class EventCalendar {
  final String date; // "yyyy-MM-dd"
  final String elderlyId;
  final String familyId;
  final int completedCount;
  final int missedCount;
  final int totalCount;

  const EventCalendar({
    required this.date,
    required this.elderlyId,
    required this.familyId,
    required this.completedCount,
    required this.missedCount,
    required this.totalCount,
  });

  factory EventCalendar.fromJson(Map<String, dynamic> json) {
    return EventCalendar(
      date: json['date'] as String,
      elderlyId: json['elderlyId'] as String,
      familyId: json['familyId'] as String,
      completedCount: json['completedCount'] as int? ?? 0,
      missedCount: json['missedCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
    );
  }

  DayStatus get status {
    if (missedCount == 0 && completedCount > 0) return DayStatus.complete;
    if (completedCount == 0) return DayStatus.missed;
    return DayStatus.partial;
  }
}