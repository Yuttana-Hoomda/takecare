import 'package:flutter/material.dart';

class Format {
  String timeToString(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour.$minute น.';
  }

  String dateToString(String date) {
    try {
      List<String> parts = date.split('-');
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int day = int.parse(parts[2]);
      DateTime parsedDate = DateTime(year, month, day);

      const List<String> thaiMonths = [
        '',
        'ม.ค.',
        'ก.พ.',
        'มี.ค.',
        'เม.ย.',
        'พ.ค.',
        'มิ.ย.',
        'ก.ค.',
        'ส.ค.',
        'ก.ย.',
        'ต.ค.',
        'พ.ย.',
        'ธ.ค.',
      ];

      final int thaiYear = parsedDate.year + 543;
      final String thaiMonth = thaiMonths[parsedDate.month];
      final int thaiDay = parsedDate.day;

      return '$thaiDay $thaiMonth $thaiYear';
    } catch (e) {
      return date;
    }
  }

  String repeatedDay(List<int>? repeatedDay) {
    if (repeatedDay == null || repeatedDay.isEmpty) {
      return 'ไม่ระบุวัน';
    }

    final days = repeatedDay.toSet().toList()..sort();
    const dayMap = {
      1: 'จันทร์',
      2: 'อังคาร',
      3: 'พุธ',
      4: 'พฤหัสบดี',
      5: 'ศุกร์',
      6: 'เสาร์',
      7: 'อาทิตย์',
    };

    if (days.length == 7) {
      return 'ทุกวัน';
    }

    const weekdays = [1, 2, 3, 4, 5];
    if (days.length == 5 && weekdays.every((d) => days.contains(d))) {
      return 'จันทร์-ศุกร์';
    }

    if (days.length == 2 && days.contains(6) && days.contains(7)) {
      return 'เสาร์-อาทิตย์';
    }

    bool isConsecutive = true;
    for (int i = 0; i < days.length - 1; i++) {
      if (days[i] + 1 != days[i + 1]) {
        isConsecutive = false;
        break;
      }
    }

    if (isConsecutive && days.length > 1) {
      return '${dayMap[days.first]}-${dayMap[days.last]}';
    }

    return days.map((d) => dayMap[d]).join(', ');
  }

  String createAtToString(DateTime createAt) {
    final String dateString = '${createAt.year}-${createAt.month}-${createAt.day}';
    final String formattedDate = dateToString(dateString);

    final TimeOfDay timeOfDay = TimeOfDay(hour: createAt.hour, minute: createAt.minute);
    final String formattedTime = timeToString(timeOfDay);

    return '$formattedDate $formattedTime';
  }
}
