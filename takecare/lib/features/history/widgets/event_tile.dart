import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:takecare/features/history/models/event_model.dart';
import 'package:takecare/features/history/screens/event_detail_screen.dart';
import 'package:takecare/constants/app_theme.dart';

enum _EventStatus { finished, missed, now, next }

class EventTile extends StatelessWidget {
  final Event event;
  final bool isLast;

  const EventTile({super.key, required this.event, required this.isLast});

  _EventStatus get _status {
    if (event.isCompleted) return _EventStatus.finished;
    if (event.status == 'missed') return _EventStatus.missed;

    final now = DateTime.now();
    final diff = event.createdAt.difference(now).inMinutes;
    if (diff < -30) return _EventStatus.missed;
    if (diff.abs() <= 30) return _EventStatus.now;
    return _EventStatus.next;
  }

  IconData _statusIcon() {
    switch (_status) {
      case _EventStatus.finished:
        return Icons.check_circle;
      case _EventStatus.missed:
        return Icons.cancel;
      case _EventStatus.now:
        return Icons.access_time_filled;
      case _EventStatus.next:
        return Icons.schedule;
    }
  }

  Color _statusColor(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCurrent = _status == _EventStatus.now;
    final statusColor = _statusColor(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
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
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(event: event),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.isFoodAnalysis)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.restaurant, size: 14, color: const Color(0xFF4DB887)),
                          const SizedBox(width: 4),
                          Text(
                            'วิเคราะห์อาหาร',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4DB887),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border(
                        left: BorderSide(color: statusColor, width: 5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  event.icon,
                                  width: 28,
                                  height: 28,
                                  colorFilter: ColorFilter.mode(statusColor, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Title
                            Expanded(
                              child: Text(
                                event.displayTitle,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent ? cs.primary : Colors.black87,
                                ),
                              ),
                            ),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_statusIcon(), size: 15, color: statusColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    _statusLabel(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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