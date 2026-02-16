import 'package:flutter/material.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/utils/format.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:takecare/utils/map_value.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.title,
    required this.time,
    required this.type,
    this.repeatedDay,
    required this.detail,
    required this.onTap,
  });

  final String title;
  final TimeOfDay time;
  final TaskType type;
  final List<int>? repeatedDay;
  final Map<String, dynamic> detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
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
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _bgIcon(type, detail),
                ),
                child: _displayIcon(type),
              ),
              const SizedBox(width: 16), // Space between icon and text


              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _buildSubtitleText(),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Gives the time some breathing room
                decoration: BoxDecoration(
                  color: Colors.grey.shade100, // Slight background to make the time stand out
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
    );
  }

  String _buildSubtitleText() {
    String detailText = _displayDetail(detail, type);
    if (type != TaskType.doctor) {
      return '${_repeatedDay(repeatedDay)} • $detailText';
    }
    return detailText;
  }
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

String _displayDetail(Map<String, dynamic> details, TaskType type) {
  if (type == TaskType.medicine) {
    return '${details['dosage'].toString()} เม็ด • ${details['instruction']}';
  } else if (type == TaskType.doctor) {
    return Format().dateToString(details['date']);
  } else {
    return '${details['description']}';
  }
}

Widget? _displayIcon(TaskType type) {
  if (type == TaskType.medicine) {
    return SvgPicture.asset(
      'assets/medicine.svg',
      width: 20,
      height: 20,
      colorFilter: const ColorFilter.mode(Color(0xFF007BFF), BlendMode.srcIn),
    );
  } else if (type == TaskType.doctor) {
    return SvgPicture.asset(
      'assets/doctor.svg',
      width: 20,
      height: 20,
      colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
    );
  } else {
    return null;
  }
}

Color? _bgIcon(TaskType type, Map<String, dynamic> detail) {
  if (type == TaskType.medicine) {
    return const Color(0xFFEFF6FF);
  } else if (type == TaskType.doctor) {
    return Colors.green[50];
  } else {
    return MapValue().customColorCreateForm(detail['color']);
  }
}