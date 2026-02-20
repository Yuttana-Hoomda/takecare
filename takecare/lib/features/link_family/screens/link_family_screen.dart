import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/link_family/widgets/phone_input_card.dart';
import 'package:takecare/features/link_family/widgets/numeric_keypad.dart';

class LinkFamilyScreen extends StatefulWidget {
  const LinkFamilyScreen({super.key});

  @override
  State<LinkFamilyScreen> createState() => _LinkFamilyScreenState();
}

class _LinkFamilyScreenState extends State<LinkFamilyScreen> {
  String _phoneNumber = '';

  void _onKeyPressed(String value) {
    setState(() {
      if (_phoneNumber.length < 10) _phoneNumber += value;
    });
  }

  void _onDelete() {
    setState(() {
      if (_phoneNumber.isNotEmpty) {
        _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
      }
    });
  }

  String _formatPhoneNumber(String raw) {
    if (raw.isEmpty) return '';
    if (raw.length <= 3) return raw;
    if (raw.length <= 6) return '(${raw.substring(0, 3)}) ${raw.substring(3)}';
    return '(${raw.substring(0, 3)}) ${raw.substring(3, 6)} - ${raw.substring(6)}';
  }

  void _onConfirm() {
    debugPrint('หมายเลขที่กรอก: $_phoneNumber');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.bgColorLight,
      appBar: AppBar(
        backgroundColor: AppTheme.bgColorLight,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: Text('เชื่อมต่อครอบครัว', style: textTheme.titleMedium),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            PhoneInputCard(formattedPhone: _formatPhoneNumber(_phoneNumber)),

            NumericKeypad(onKeyPressed: _onKeyPressed, onDelete: _onDelete),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _phoneNumber.length == 10 ? _onConfirm : null,
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: Text(
                    'ยืนยันบัญชี',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    disabledBackgroundColor: AppTheme.secondary,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: AppTheme.primaryColor.withOpacity(
                      0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
