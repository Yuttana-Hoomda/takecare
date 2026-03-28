import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Make sure to import provider
import 'package:takecare/components/build_text_field.dart';
import 'package:takecare/features/auth/screens/select_role_screen.dart';

import '../../../constants/app_theme.dart';
import '../providers/auth_provider.dart'; // Import your AuthProvider

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    pinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      if (pinController.text != confirmPinController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน')),
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.createInitialUser(
        fullNameController.text.trim(),
        phoneController.text.trim(),
        pinController.text,
      );

      // If successful, navigate to the next screen to update the rest of the profile!
      if (success && mounted) {
        Navigator.pushReplacement( // Use pushReplacement so they can't "back" into registration
          context,
          MaterialPageRoute(builder: (context) => const SelectRoleScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage ?? 'Registration failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('สร้างบัญชี')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          // Wrapped Column in a Form widget
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView( // Prevents pixel overflow on small screens when keyboard opens
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('ชื่อผู้ใช้', style: textTheme.titleMedium),
                        const SizedBox(height: 10),
                        BuildTextField(
                          controller: fullNameController,
                          hint: 'ชื่อผู้ใช้',
                          isRequired: true,
                          placeholder: 'John Doe',
                        ),
                        const SizedBox(height: 20),
                        Text('เบอร์โทรศัพท์มือถือ', style: textTheme.titleMedium),
                        const SizedBox(height: 10),
                        BuildTextField(
                          controller: phoneController,
                          hint: 'เบอร์โทรศัพท์มือถือ',
                          isRequired: true,
                          placeholder: '0812345678', // Removed dashes from placeholder so they know to just type numbers
                          maxLength: 10,
                          keyboardType: TextInputType.phone, // Pops up the number pad instead of the alphabet keyboard
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, // Physically blocks letters and dashes from being pasted or typed
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text('รหัสผ่าน', style: textTheme.titleMedium),
                        const SizedBox(height: 10),
                        BuildTextField(
                          controller: pinController,
                          hint: 'รหัสผ่าน 6 หลัก',
                          isRequired: true,
                          placeholder: '••••••',
                          // Ideally, add obscureText: true in your BuildTextField component!
                        ),
                        const SizedBox(height: 20),
                        Text('ยืนยันรหัสผ่าน', style: textTheme.titleMedium),
                        const SizedBox(height: 10),
                        BuildTextField(
                          controller: confirmPinController, // Used the new controller
                          hint: 'ยืนยันรหัสผ่าน 6 หลัก',
                          isRequired: true,
                          placeholder: '••••••',
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    // Disable button if loading
                    onPressed: isLoading ? null : _handleRegistration,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "สร้างบัญชี",
                      style: textTheme.labelLarge?.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('มีบัญชีอยู่แล้วใช่ไหม?'),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'เข้าสู่ระบบ',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}