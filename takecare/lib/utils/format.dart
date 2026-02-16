import 'package:flutter/material.dart';

class Format {
  String timeToString(TimeOfDay time) {
    return '${time.hour}.${time.minute} น.';
  }

  String dateToString(String date) {
    final DateTime parsedDate = DateTime.parse(date);
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

    final int day = parsedDate.day;
    final String month = thaiMonths[parsedDate.month];
    final int yearBE = parsedDate.year + 543;

    return '$day $month $yearBE';
  }
}