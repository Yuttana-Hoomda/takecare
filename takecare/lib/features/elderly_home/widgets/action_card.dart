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
              title: "รายการที่ต้องทำ",
              subtitle: "เหลืออีก 3 รายการ",
              imagePath: 'assets/icons/list.png',
              onTap: () {},
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ActionCard(
              title: "วิเคราะห์อาหาร",
              subtitle: "",
              imagePath: 'assets/icons/food.png',
              onTap: () {},
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      ActionCardLandscape(
        title: "ประวัติย้อนหลัง",
        subtitle: "สรุปรายเดือน",
        imagePath: "assets/icons/history.png",
        onTap: () {},
      ),
    ],
  );
}