import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';

class TimeScrollPicker extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final int minHour;
  final int maxHour;
  final String title;
  final ValueChanged<TimeOfDay> onConfirmed;

  const TimeScrollPicker({
    super.key,
    required this.initialHour,
    required this.initialMinute,
    required this.minHour,
    required this.maxHour,
    required this.title,
    required this.onConfirmed,
  });

  static Future<void> show({
    required BuildContext context,
    required int initialHour,
    required int initialMinute,
    required int minHour,
    required int maxHour,
    required String title,
    required ValueChanged<TimeOfDay> onConfirmed,
  }) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: TimeScrollPicker(
          initialHour: initialHour,
          initialMinute: initialMinute,
          minHour: minHour,
          maxHour: maxHour,
          title: title,
          onConfirmed: onConfirmed,
        ),
      ),
    );
  }

  @override
  State<TimeScrollPicker> createState() => _TimeScrollPickerState();
}

class _TimeScrollPickerState extends State<TimeScrollPicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  final List<int> _minutes = [0, 15, 30, 45];

  // Large number to simulate infinite loop
  static const int _loopCount = 1000;

  List<int> get _hours => List.generate(
    widget.maxHour - widget.minHour + 1,
        (i) => widget.minHour + i,
  );

  // Middle index so user can scroll both up and down from start
  int get _hourMiddleIndex =>
      (_loopCount ~/ 2) * _hours.length + _hours.indexOf(_selectedHour);

  int get _minuteMiddleIndex =>
      (_loopCount ~/ 2) * _minutes.length + _minutes.indexOf(_selectedMinute);

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialHour.clamp(widget.minHour, widget.maxHour);
    _selectedMinute = _minutes.contains(widget.initialMinute)
        ? widget.initialMinute
        : 0;

    _hourController = FixedExtentScrollController(
      initialItem: _hourMiddleIndex,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _minuteMiddleIndex,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D232E),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'เลื่อนเพื่อเลือกเวลา',
            style: TextStyle(fontSize: 14, color: Colors.blueGrey),
          ),
          const SizedBox(height: 24),

          // Column labels
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  'ชั่วโมง',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 90,
                child: Text(
                  'นาที',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Scroll wheels
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Highlight bar
                Container(
                  height: 48,
                  width: 196,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ Looping hour wheel
                    SizedBox(
                      width: 90,
                      child: ListWheelScrollView.useDelegate(
                        controller: _hourController,
                        itemExtent: 48,
                        perspective: 0.003,
                        diameterRatio: 2.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          // ✅ modulo maps any index back to actual hour value
                          final hour = _hours[index % _hours.length];
                          setState(() => _selectedHour = hour);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          // ✅ large childCount = feels infinite
                          childCount: _hours.length * _loopCount,
                          builder: (context, index) {
                            final hour = _hours[index % _hours.length];
                            return _wheelItem(
                              hour.toString().padLeft(2, '0'),
                              isSelected: hour == _selectedHour,
                            );
                          },
                        ),
                      ),
                    ),

                    // Colon
                    const SizedBox(
                      width: 16,
                      child: Text(
                        ':',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D232E),
                        ),
                      ),
                    ),

                    // ✅ Looping minute wheel
                    SizedBox(
                      width: 90,
                      child: ListWheelScrollView.useDelegate(
                        controller: _minuteController,
                        itemExtent: 48,
                        perspective: 0.003,
                        diameterRatio: 2.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          // ✅ modulo maps any index back to actual minute value
                          final minute = _minutes[index % _minutes.length];
                          setState(() => _selectedMinute = minute);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: _minutes.length * _loopCount,
                          builder: (context, index) {
                            final minute = _minutes[index % _minutes.length];
                            return _wheelItem(
                              minute.toString().padLeft(2, '0'),
                              isSelected: minute == _selectedMinute,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // OK button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                widget.onConfirmed(
                  TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'ตกลง',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wheelItem(String label, {bool isSelected = false}) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 22,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.grey.shade400,
        ),
      ),
    );
  }
}