import 'package:flutter/material.dart';

class MapValue {
  Color customColorCreateForm(int value) {
    final Map<int, Color> colorMap = {
      1: ?Colors.yellow[200],
      2: ?Colors.purple[200],
      3: ?Colors.green[200],
      4: ?Colors.pink[200],
    };

    return colorMap[value] ?? Colors.grey; // default ถ้าไม่เจอค่า
  }
}