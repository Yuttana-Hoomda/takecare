import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:takecare/components/build_text_field.dart';
import 'package:takecare/features/auth/screens/select_role_screen.dart';
import '../../../components/loading_overlay.dart';
import '../../../constants/app_theme.dart';
import '../providers/auth_provider.dart';

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

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SelectRoleScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Registration failed'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'กำลังสร้างบัญชี...',
      child: Scaffold(
        resizeToAvoidBottomInset: false, // Prevents the keyboard from pushing the UI up
        appBar: AppBar(title: const Text('สร้างบัญชี')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('ชื่อผู้ใช้', style: textTheme.titleMedium),
                          const SizedBox(height: 10),
                          BuildTextField(
                            controller: fullNameController,
                            hint: 'ชื่อผู้ใช้',
                            isRequired: true,
                            placeholder: 'สมชาย',
                          ),
                          const SizedBox(height: 20),
                          Text('เบอร์โทรศัพท์มือถือ', style: textTheme.titleMedium),
                          const SizedBox(height: 10),
                          BuildTextField(
                            controller: phoneController,
                            hint: 'เบอร์โทรศัพท์มือถือ',
                            isRequired: true,
                            placeholder: '0812345678',
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text('รหัสผ่าน', style: textTheme.titleMedium),
                          const SizedBox(height: 10),
                          BuildTextField(
                            controller: pinController,
                            hint: 'รหัสผ่าน 6 หลัก',
                            isRequired: true,
                            placeholder: 'รหัสผ่านอย่างน้อย 6 ตัว',
                          ),
                          const SizedBox(height: 20),
                          Text('ยืนยันรหัสผ่าน', style: textTheme.titleMedium),
                          const SizedBox(height: 10),
                          BuildTextField(
                            controller: confirmPinController,
                            hint: 'ยืนยันรหัสผ่าน 6 หลัก',
                            isRequired: true,
                            placeholder: 'ยืนยันรหัสผ่าน',
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
                      onPressed: isLoading ? null : _handleRegistration,
                      child: Text(
                        'สร้างบัญชี',
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
      ),
    );
  }
}