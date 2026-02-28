import 'package:flutter/material.dart';
import 'package:takecare/features/elderly_home/models/event_task.dart';

class DayStatusDot extends StatelessWidget {
  final int day;
  final DayStatus? status; // null = ไม่มีข้อมูลวันนี้
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

          // จุดเล็กๆ ด้านล่างเมื่อมีข้อมูลแต่ยังไม่ได้เลือก
          if (status != null && !isSelected)
            Positioned(
              bottom: 4,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _statusColor(cs),
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

  Color _borderColor(ColorScheme cs) {
    if (isSelected) return cs.primary;
    return _statusColor(cs);
  }

  Color _bgColor(ColorScheme cs) {
    if (isSelected) return cs.primary;
    switch (status) {
      case DayStatus.complete: return cs.tertiaryContainer;
      case DayStatus.missed:   return cs.errorContainer;
      case DayStatus.partial:  return cs.secondaryContainer;
      case null:               return Colors.transparent;
    }
  }

  Color _textColor(ColorScheme cs) {
    if (isSelected) return cs.onPrimary;
    switch (status) {
      case DayStatus.complete: return cs.onTertiaryContainer;
      case DayStatus.missed:   return cs.onErrorContainer;
      case DayStatus.partial:  return cs.onSecondaryContainer;
      case null:               return cs.onSurface;
    }
  }

  Color _statusColor(ColorScheme cs) {
    switch (status) {
      case DayStatus.complete: return cs.tertiary;
      case DayStatus.missed:   return cs.error;
      case DayStatus.partial:  return cs.secondary;
      case null:               return Colors.transparent;
    }
  }
}