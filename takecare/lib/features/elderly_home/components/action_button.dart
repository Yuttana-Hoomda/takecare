import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final String icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDarkMode 
              ? Colors.white.withOpacity(0.05) 
              :  AppTheme.secondary ,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: iconColor.withOpacity(0.1),
            highlightColor: iconColor.withOpacity(0.05),
            child: Padding(
              // ปรับ Padding ให้เท่ากับ ProgressCard (vertical: 20, horizontal: 12)
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ปรับขนาดไอคอนให้ใกล้เคียงกับวงกลม Progress (90x90)
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        icon, 
                        width: 45,
                        height: 45,
                        color: iconColor
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  // เพิ่มพื้นที่ด้านล่างเพื่อให้ความสูงรวมเท่ากับ ProgressCard ที่มี sublabel
                  const SizedBox(height: 18), 
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
