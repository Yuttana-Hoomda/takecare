import 'package:flutter/material.dart';
import 'package:takecare/features/caregiver_home/widgets/progress_card.dart';
import 'package:takecare/features/elderly_home/components/action_button.dart';
import 'package:takecare/features/caregiver_home/widgets/progress_card.dart';
import 'package:takecare/constants/app_theme.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ProgressCard(
            label: 'Progress',
            valueText: '50%',
            sublabel: '4/5 doses taken',
            progress: 0.5,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
            ActionButton(label: "เช็กอาหาร", icon: "assets/icons/food.png", iconColor: AppTheme.primaryColor, bgColor: Colors.white, onTap: () => {} )
          ),
      ],
    );
  }
}
