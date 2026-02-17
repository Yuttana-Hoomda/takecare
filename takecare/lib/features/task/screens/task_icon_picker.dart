import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants/app_theme.dart';

class TaskIconPicker extends StatelessWidget {
  const TaskIconPicker({
    super.key,
    required this.icons,
    required this.selectedIcon,
    required this.onTapIcon
  });

  final List<String> icons;
  final int selectedIcon;
  final ValueChanged<int> onTapIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < 3; i++)
          GestureDetector(
            onTap: () => onTapIcon(i),
            child: Container(
              width: 110,
              padding: const EdgeInsets.symmetric(vertical: 26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedIcon == i ? AppTheme.primaryColor : Colors.transparent,
                  width: 2
                )
              ),
              child: SvgPicture.asset(
                icons[i],
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  selectedIcon == i ? AppTheme.primaryColor : Colors.black54,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
