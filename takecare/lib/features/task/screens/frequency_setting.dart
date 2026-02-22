import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/task/screens/day_picker_row.dart';
import 'package:takecare/utils/format.dart';

final List<String> toggleList = ['ทำซ้ำ', 'ครั้งเดียว'];

class FrequencySetting extends StatefulWidget {
  final List<int> selectedDays;
  final ValueChanged<int> onDayTapped;
  final TimeOfDay? selectedTime;
  final String selectedDate;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  const FrequencySetting({
    super.key,
    required this.selectedDays,
    required this.onDayTapped,
    required this.selectedDate,
    this.selectedTime,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  @override
  State<FrequencySetting> createState() => _FrequencySettingState();
}

class _FrequencySettingState extends State<FrequencySetting> {
  final List<bool> _isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    bool isRepeatMode = _isSelected[0];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _pickerButton(
            widget.selectedTime != null
                ? Format().timeToString(widget.selectedTime!)
                : 'เวลา',
            Icons.alarm_rounded,
            widget.onSelectTime,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              return ToggleButtons(
                isSelected: _isSelected,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _isSelected.length; i++) {
                      _isSelected[i] = i == index;
                    }
                  });
                },
                fillColor: AppTheme.secondary,
                selectedColor: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
                constraints: BoxConstraints.expand(
                  width: (constraints.maxWidth - 4) / 2,
                  height: 40,
                ),
                children: toggleList.map((String title) {
                  return Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  );
                }).toList(),
              );
            },
          ),
          if (isRepeatMode) ...[
            const SizedBox(height: 12,),
            DayPickerRow(
              selectedDays: widget.selectedDays,
              onDayTapped: widget.onDayTapped,
            ),
          ] else ...[
            const SizedBox(height: 12,),
            _pickerButton(
              widget.selectedDate.isNotEmpty
                  ? Format().dateToString(widget.selectedDate)
                  : '---',
              Icons.calendar_month_rounded,
              widget.onSelectDate,
            ),
          ],
        ],
      ),
    );
  }

  Widget _pickerButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.bgColorLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [Icon(icon), const SizedBox(width: 12), Text(label)],
        ),
      ),
    );
  }
}
