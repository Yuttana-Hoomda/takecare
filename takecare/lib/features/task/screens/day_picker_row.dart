import 'package:flutter/material.dart';

import '../../../constants/app_theme.dart';

const List<String> weekDays = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

class DayPickerRow extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<int> onDayTapped;

  const DayPickerRow({
    super.key,
    required this.selectedDays,
    required this.onDayTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < 7; i++)
          GestureDetector(
            onTap: () => onDayTapped(i),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selectedDays.contains(i)
                    ? AppTheme.primaryColor
                    : AppTheme.bgColorLight,
              ),
              child: Text(
                weekDays[i],
                style: TextStyle(
                  color: selectedDays.contains(i)
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
