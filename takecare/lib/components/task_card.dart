import 'package:flutter/material.dart';
import 'package:takecare/utils/format.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
    this.repeatedDay,
    this.date,
    this.note,
    required this.onTap,
  });

  final String title;
  final TimeOfDay time;
  final String icon;
  final List<int>? repeatedDay;
  final String? date;
  final String? note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:110,
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounds the Card's corners
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Spacing inside the card
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _icon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _buildDateText(date),
                              style: Theme.of(context).textTheme.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if(note != null && note!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                note!,
                                style: Theme.of(context).textTheme.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                    ],
                  ),
                ),
                const SizedBox(width: 12), // Space before the trailing widget

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    Format().timeToString(time),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _repeatedDay(List<int>? repeatedDay) {
    if (repeatedDay == null || repeatedDay.isEmpty) {
      return 'ไม่ระบุวัน';
    }

    final days = repeatedDay.toSet().toList()..sort();
    const dayMap = {
      1: 'จันทร์',
      2: 'อังคาร',
      3: 'พุธ',
      4: 'พฤหัสบดี',
      5: 'ศุกร์',
      6: 'เสาร์',
      7: 'อาทิตย์',
    };

    if (days.length == 7) {
      return 'ทุกวัน';
    }

    const weekdays = [1, 2, 3, 4, 5];
    if (days.length == 5 && weekdays.every((d) => days.contains(d))) {
      return 'จันทร์-ศุกร์';
    }

    if (days.length == 2 && days.contains(6) && days.contains(7)) {
      return 'เสาร์-อาทิตย์';
    }

    bool isConsecutive = true;
    for (int i = 0; i < days.length - 1; i++) {
      if (days[i] + 1 != days[i + 1]) {
        isConsecutive = false;
        break;
      }
    }

    if (isConsecutive && days.length > 1) {
      return '${dayMap[days.first]}-${dayMap[days.last]}';
    }

    return days.map((d) => dayMap[d]).join(', ');
  }

  Widget _icon() {
    final Color bgColor;
    final Color iconColor;

    if(icon.contains('medicine')) {
      bgColor = Color(0xFFEFF6FF);
      iconColor = Color(0xFF007BFF);
    } else if(icon.contains('doctor')) {
      bgColor = Colors.green[50]!;
      iconColor = Colors.green;
    } else {
      bgColor = Colors.orange[50]!;
      iconColor = Colors.orange;
    }

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: SvgPicture.asset(
        icon,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
            iconColor,
            BlendMode.srcIn
        ),
      ),
    );
  }

  String _buildDateText(String? date) {
    if(date != null && date.isNotEmpty) {
      return Format().dateToString(date);
    } else {
      return _repeatedDay(repeatedDay);
    }
  }
}
