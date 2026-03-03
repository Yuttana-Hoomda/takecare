import 'package:flutter/material.dart';
import '../../elderly_history/models/event_task.dart';

class DayStatusDot extends StatelessWidget {
  final int day;
  final DayStatus? status;
  final bool isSelected;
  final VoidCallback onTap;

  const DayStatusDot({
    super.key,
    required this.day,
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: status != null ? onTap : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _bgColor(cs),
              border: Border.all(color: _borderColor(cs), width: 2.2),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textColor(cs),
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }

  /// selected → ใช้สี onPrimary บน primary
  /// complete → tertiary (สีเขียวที่ generate จาก seed)
  /// missed   → error
  /// partial  → secondary
  /// null     → ไม่มีขอบ

  // complete → เขียว, partial → ส้ม, missed → แดง
  static const _green       = Color(0xFF4DB887);
  static const _greenBg     = Color(0xFFEAF7F1);
  static const _orange      = Color(0xFFFFAA55);
  static const _orangeBg    = Color(0xFFFFF4E6);
  static const _red         = Color(0xFFFF7F7F);
  static const _redBg       = Color(0xFFFFF0F0);

  Color _borderColor(ColorScheme cs) {
    if (isSelected) return cs.primary;
    switch (status) {
      case DayStatus.complete: return _green;
      case DayStatus.partial:  return _orange;
      case DayStatus.missed:   return _red;
      case null:               return Colors.transparent;
    }
  }

  Color _bgColor(ColorScheme cs) {
    if (isSelected) return cs.primary;
    switch (status) {
      case DayStatus.complete: return _greenBg;
      case DayStatus.partial:  return _orangeBg;
      case DayStatus.missed:   return _redBg;
      case null:               return Colors.transparent;
    }
  }

  Color _textColor(ColorScheme cs) {
    if (isSelected) return cs.onPrimary;
    switch (status) {
      case DayStatus.complete: return _green;
      case DayStatus.partial:  return _orange;
      case DayStatus.missed:   return _red;
      case null:               return cs.onSurface;
    }
  }
}