import 'package:flutter/material.dart';
import '../components/action_card.dart';
import '../components/action_card_landscape.dart';

Widget buildActionCards() {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: ActionCard(
              title: "My Tasks",
              subtitle: "3 Remaining",
              imagePath: 'assets/icons/list.png',
              onTap: () {},
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ActionCard(
              title: "Check Food",
              subtitle: "Log Lunch",
              imagePath: 'assets/icons/food.png',
              onTap: () {},
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      ActionCardLandscape(
        title: "View History",
        subtitle: "Weekly Progress",
        imagePath: "assets/icons/history.png",
        onTap: () {},
      ),
    ],
  );
}