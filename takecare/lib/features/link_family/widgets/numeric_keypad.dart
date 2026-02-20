import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';

/// Card ก้อนที่ 2: ปุ่มกดตัวเลข (Reusable Component)
class NumericKeypad extends StatelessWidget {
  final void Function(String value) onKeyPressed;
  final VoidCallback onDelete;

  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onDelete,
  });

  static const List<List<String?>> _keyLayout = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    [null, '0', 'del'],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.secondary),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: _keyLayout.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((key) => _buildKey(context, key)).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildKey(BuildContext context, String? key) {
    if (key == null) return const SizedBox(width: 90, height: 64);

    if (key == 'del') {
      return _KeyButton(
        onTap: onDelete,
        child: const Icon(
          Icons.backspace_outlined,
          size: 22,
          color: AppTheme.subtitle,
        ),
      );
    }

    return _KeyButton(
      onTap: () => onKeyPressed(key),
      child: Text(
        key,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _KeyButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 64,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            splashColor: AppTheme.primaryColor.withOpacity(0.15),
            highlightColor: AppTheme.primaryColor.withOpacity(0.08),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
