import 'package:flutter/material.dart';

class Format {
  String timeToString(TimeOfDay time) {
    return '${time.hour}.${time.minute} น.';
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
}
