import 'package:flutter/material.dart';
import 'package:takecare/features/elderly_home/components/action_button.dart';
import '';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ActionButton(
            label: 'งานของฉัน',
            icon: 'assets/icons/history.png',
            iconColor: const Color(0xFFFF8C42),
            bgColor: const Color(0xFFFFF0E6),
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActionButton(
            label: 'เช็คอาหาร',
            icon:'assets/icons/food.png',
            iconColor: const Color(0xFF4DB887),
            bgColor: const Color(0xFFE8F8EE),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

