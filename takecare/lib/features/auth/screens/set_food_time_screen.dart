import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/auth/providers/on_boarding_provider.dart';
import 'package:takecare/features/auth/screens/AuthWrapper.dart';
import 'package:takecare/features/elderly_home/screens/elderly_home_screen.dart';

import '../../../components/time_scroll_picker.dart';

class SetFoodTimeScreen extends StatelessWidget {
  const SetFoodTimeScreen({super.key});

  static const _mealRanges = {
    'breakfast': (start: 7, end: 10),
    'lunch': (start: 11, end: 14),
    'dinner': (start: 17, end: 21),
  };

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime({
    required BuildContext context,
    required TimeOfDay currentTime,
    required String meal,
    required String title,
    required Function(TimeOfDay) onConfirmed,
  }) async {
    final range = _mealRanges[meal]!;

    await TimeScrollPicker.show(
      context: context,
      initialHour: currentTime.hour,
      initialMinute: currentTime.minute,
      minHour: range.start,
      maxHour: range.end,
      onConfirmed: (picked) => onConfirmed(picked),
      title: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme
        .of(context)
        .textTheme;
    final boardingProvider = Provider.of<OnBoardingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกเวลารับประทานอาหารของคุณ'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'โปรดเลือกเวลาที่คุณรับประทานอาหาร\nเป็นประจำ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      _foodTimeCard(
                        context: context,
                        icon: Icons.wb_twilight,
                        title: 'เช้า',
                        value: _formatTime(boardingProvider.breakfastTime),
                        rangeLabel: '07:00 – 11:00',
                        onTap: () =>
                            _pickTime(
                              context: context,
                              currentTime: boardingProvider.breakfastTime,
                              meal: 'breakfast',
                              onConfirmed: boardingProvider.setBreakfastTime,
                              title: 'เวลาทานอาหารเช้า',
                            ),
                      ),
                      const SizedBox(height: 16),

                      _foodTimeCard(
                        context: context,
                        icon: Icons.wb_sunny,
                        title: 'กลางวัน',
                        value: _formatTime(boardingProvider.lunchTime),
                        rangeLabel: '11:00 – 14:00',
                        onTap: () =>
                            _pickTime(
                              context: context,
                              currentTime: boardingProvider.lunchTime,
                              meal: 'lunch',
                              onConfirmed: boardingProvider.setLunchTime,
                              title: 'เวลาทานอาหารกลางวัน',
                            ),
                      ),
                      const SizedBox(height: 16),

                      _foodTimeCard(
                        context: context,
                        icon: Icons.nightlight_round,
                        title: 'เย็น',
                        value: _formatTime(boardingProvider.dinnerTime),
                        rangeLabel: '17:00 – 21:00',
                        onTap: () =>
                            _pickTime(
                              context: context,
                              currentTime: boardingProvider.dinnerTime,
                              meal: 'dinner',
                              onConfirmed: boardingProvider.setDinnerTime,
                              title: 'เวลาทานอาหารเย็น',
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await authProvider.updateElderProfile(
                        ncdConditions: boardingProvider.diseases,
                        foodTime: boardingProvider.currentFoodTime
                    );

                    if (success && context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthWrapper(),
                        ),
                            (route) => false,
                      );

                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(authProvider.errorMessage ?? 'เกิดข้อผิดพลาด')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'ถัดไป',
                    style: textTheme.labelLarge?.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _foodTimeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String rangeLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F1FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF007AFF), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D232E),
                  ),
                ),
                Text(
                  rangeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007AFF),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF007AFF),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}