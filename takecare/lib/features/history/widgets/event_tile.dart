import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:takecare/features/history/models/event_model.dart';

enum _EventStatus { finished, missed, now, next }

class EventTile extends StatefulWidget {
  final Event event;
  final bool isLast;

  const EventTile({super.key, required this.event, required this.isLast});

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  bool _markedComplete = false;

  _EventStatus get _status {
    if (widget.event.isCompleted || _markedComplete) return _EventStatus.finished;
    if (widget.event.status == 'missed') return _EventStatus.missed;

    // เช็คเวลา createdAt เทียบกับตอนนี้
    final now = DateTime.now();
    final eventTime = widget.event.createdAt;
    final diff = eventTime.difference(now).inMinutes;

    if (diff < -30) return _EventStatus.missed;
    if (diff.abs() <= 30) return _EventStatus.now;
    return _EventStatus.next;
  }

  Color _dotColor(BuildContext context) {
    switch (_status) {
      case _EventStatus.finished:
        return const Color(0xFF4DB887);
      case _EventStatus.missed:
        return const Color(0xFFFF7F7F);
      case _EventStatus.now:
        return Theme.of(context).colorScheme.primary;
      case _EventStatus.next:
        return Theme.of(context).colorScheme.outlineVariant;
    }
  }

  Color _leftBorderColor() {
    switch (_status) {
      case _EventStatus.finished:
        return const Color(0xFF4DB887);
      case _EventStatus.missed:
        return const Color(0xFFFF7F7F);
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

  Color _statusLabelColor() {
    switch (_status) {
      case _EventStatus.finished:
        return const Color(0xFF4DB887);
      case _EventStatus.missed:
        return const Color(0xFFFF7F7F);
      case _EventStatus.now:
        return Theme.of(context).colorScheme.primary;
      case _EventStatus.next:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCurrent = _status == _EventStatus.now;
    final Color cardBg =
    isCurrent ? cs.primary : cs.surfaceContainerLow;
    final Color titleColor =
    isCurrent ? cs.onPrimary : cs.onSurface;
    final Color subtitleColor = isCurrent
        ? cs.onPrimary.withOpacity(0.8)
        : cs.onSurfaceVariant;

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
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: cs.outlineVariant,
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
                border: isCurrent
                    ? null
                    : Border(
                    left: BorderSide(
                        color: _leftBorderColor(), width: 4)),
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
                          color: isCurrent
                              ? cs.onPrimary.withOpacity(0.8)
                              : _statusLabelColor(),
                        ),
                      ),
                      if (widget.event.type == 'food_analysis')
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? Colors.white.withOpacity(0.2)
                                : const Color(0xFFE8F8EE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'วิเคราะห์อาหาร',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isCurrent
                                  ? Colors.white
                                  : const Color(0xFF4DB887),
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
                          color: isCurrent
                              ? Colors.white.withOpacity(0.2)
                              : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            widget.event.icon,
                            width: 20,
                            height: 20,
                            colorFilter: isCurrent
                                ? const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn)
                                : null,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.event.displayTitle,
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
                  if (widget.event.displaySubtitle != null &&
                      widget.event.displaySubtitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        widget.event.displaySubtitle!,
                        style: TextStyle(
                            fontSize: 13, color: subtitleColor),
                      ),
                    ),
                  // Mark as Completed button
                  if (_status == _EventStatus.missed)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              setState(() => _markedComplete = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7F7F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('บันทึกว่าเสร็จสิ้น'),
                        ),
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
                            backgroundColor: Colors.white,
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