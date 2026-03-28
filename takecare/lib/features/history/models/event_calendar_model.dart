enum DayStatus { complete, partial, missed }

/// ข้อมูลสรุปของแต่ละวัน — ใช้แสดง dot ใน calendar
class EventCalendar {
  final String date; // จะถูกเก็บในรูปแบบ "yyyy-MM-dd"
  final String? elderlyId;
  final String familyId;
  final int completedCount;
  final int missedCount;
  final int totalCount;

  const EventCalendar({
    required this.date,
    this.elderlyId,
    required this.familyId,
    required this.completedCount,
    required this.missedCount,
    required this.totalCount,
  });

  factory EventCalendar.fromJson(Map<String, dynamic> json) {
    String rawDate = json['date'] as String? ?? '';
    // ตัดเอาเฉพาะ yyyy-MM-dd (เช่น "2026-03-15") เพื่อให้ตรงกับ Key ที่ใช้หาในปฏิทิน
    String formattedDate = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;

    return EventCalendar(
      date: formattedDate,
      elderlyId: json['elderlyId'] as String?,
      familyId: json['familyId'] as String? ?? '',
      completedCount: json['completedCount'] as int? ?? 0,
      missedCount: json['missedCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
    );
  }

  DayStatus get status {
    // ถ้าไม่มีงานเลย ไม่ต้องแสดงสถานะ (จะกลายเป็นสีเทาใน UI)
    if (totalCount == 0) return DayStatus.missed; 

    // ถ้าเสร็จหมดทุกงาน
    if (completedCount == totalCount && totalCount > 0) {
      return DayStatus.complete; // เขียว
    }
    
    // ถ้าพลาดหมดทุกงาน
    if (missedCount == totalCount && totalCount > 0) {
      return DayStatus.missed; // แดง
    }
    
    // มีทั้งเสร็จและพลาด
    return DayStatus.partial; // เหลือง
  }
}