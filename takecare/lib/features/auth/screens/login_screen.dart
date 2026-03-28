import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; //
import 'package:takecare/components/build_text_field.dart';
import 'package:takecare/features/auth/screens/register_screen.dart';
import '../../../constants/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icons/app_logo.png',
                      width: 200,
                      height: 200,
                    ),
                    Text(
                      'เข้าสู่ระบบ',
                      style: textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    BuildTextField(
                      controller: phoneController,
                      hint: 'เบอร์มือถือ',
                      isRequired: true,
                      icon: Icons.phone,
                      placeholder: 'เบอร์โทรศัพท์',
                    ),
                    const SizedBox(height: 18),
                    BuildTextField(
                      controller: passwordController,
                      hint: 'รหัส',
                      isRequired: true,
                      icon: Icons.lock,
                      placeholder: 'รหัส',
                    ),
                    const SizedBox(height: 24),
                    authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: SizedBox(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await authProvider.signIn(
                                      phoneController.text.trim(),
                                      passwordController.text.trim(),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("LoginScreen Failed: $e"),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  "เข้าสู่ระบบ",
                                  style: textTheme.labelLarge?.copyWith(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ยังไม่มีบัญชีใช่ไหม?'),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'สร้างบัญชี',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
