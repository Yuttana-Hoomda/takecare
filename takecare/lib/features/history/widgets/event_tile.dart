import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:takecare/features/history/models/event_model.dart';
import 'package:takecare/constants/app_theme.dart';

enum _EventStatus { finished, missed, now, next }

class EventTile extends StatelessWidget {
  final Event event;
  final bool isLast;

  const EventTile({super.key, required this.event, required this.isLast});

  _EventStatus get _status {
    if (event.isCompleted || event.status == 'completed') return _EventStatus.finished;
    if (event.status == 'missed') return _EventStatus.missed;

    final now = DateTime.now();
    final eventTime = event.createdAt;
    final diff = eventTime.difference(now).inMinutes;

    if (diff < -30) return _EventStatus.missed;
    if (diff.abs() <= 30) return _EventStatus.now;
    return _EventStatus.next;
  }

  Color _dotColor(BuildContext context) {
    switch (_status) {
      case _EventStatus.finished:
        return AppTheme.success;
      case _EventStatus.missed:
        return AppTheme.error;
      case _EventStatus.now:
        return Theme.of(context).colorScheme.primary;
      case _EventStatus.next:
        return Theme.of(context).colorScheme.outlineVariant;
    }
  }

  Color _leftBorderColor() {
    switch (_status) {
      case _EventStatus.finished:
        return AppTheme.success;
      case _EventStatus.missed:
        return AppTheme.error;
      case _EventStatus.now:
        return Colors.transparent;
      case _EventStatus.next:
        return const Color(0xFFCCCCCC);
    }
  }

  String _statusLabel() {
    switch (_status) {
      case _EventStatus.finished:
        return 'เสร็จสิ้น';
      case _EventStatus.missed:
        return 'พลาด';
      case _EventStatus.now:
        return 'ตอนนี้';
      case _EventStatus.next:
        return 'ถัดไป';
    }
  }

  Color _statusLabelColor(BuildContext context) {
    switch (_status) {
      case _EventStatus.finished:
        return AppTheme.success;
      case _EventStatus.missed:
        return AppTheme.error;
      case _EventStatus.now:
        return Theme.of(context).colorScheme.primary;
      case _EventStatus.next:
        return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCurrent = _status == _EventStatus.now;
    final Color cardBg = Colors.white;
    final Color titleColor = isCurrent ? cs.primary : cs.onSurface;
    final Color subtitleColor = cs.onSurfaceVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline dot + line
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotColor(context),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: cs.outlineVariant.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border(
                    left: BorderSide(
                        color: _leftBorderColor(), width: 4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // status label + type badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _statusLabel(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusLabelColor(context),
                        ),
                      ),
                      if (event.isFoodAnalysis)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8EE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'วิเคราะห์อาหาร',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4DB887),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // icon + title
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            event.icon,
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          event.displayTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // subtitle (note)
                  if (event.displaySubtitle != null &&
                      event.displaySubtitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        event.displaySubtitle!,
                        style: TextStyle(
                            fontSize: 13, color: subtitleColor),
                      ),
                    ),
                  // View Details button
                  if (isCurrent)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('ดูรายละเอียด'),
                        ),
                      ),
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