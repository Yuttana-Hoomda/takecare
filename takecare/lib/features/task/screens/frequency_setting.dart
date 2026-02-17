import 'package:flutter/material.dart';
import 'package:takecare/features/task/screens/day_picker_row.dart';

import '../../../constants/app_theme.dart';

class FrequencySetting extends StatelessWidget {
  final String currentValue;
  final List<String> frequencyOptions;
  final ValueChanged<String?> onChanged;
  final List<int> selectedDays;
  final ValueChanged<int> onDayTapped;

  const FrequencySetting({
    super.key,
    required this.currentValue,
    required this.frequencyOptions,
    required this.onChanged,
    required this.selectedDays,
    required this.onDayTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.repeat_rounded,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ความถี่',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ตั้งค่าวันที่แจ้งเตือน',
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor
                    ),
                    value: currentValue,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryColor,),
                    items: frequencyOptions.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentValue == 'สัปดาห์') ...[
                const Text('ทำซ้ำ'),
                DayPickerRow(
                  selectedDays: selectedDays,
                  onDayTapped: onDayTapped,
                ),
              ] else ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [Text('ตั้งค่าสำหรับรายวัน')],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
