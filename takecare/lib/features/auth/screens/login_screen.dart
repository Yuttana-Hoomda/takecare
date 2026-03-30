import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/components/build_text_field.dart';
import 'package:takecare/features/auth/screens/register_screen.dart';
import '../../../components/loading_overlay.dart';
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

  Future<void> _handleLogin(AuthProvider authProvider) async {
    await authProvider.signIn(
      phoneController.text.trim(),
      passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ watch — rebuilds when errorMessage changes
    final authProvider = context.watch<AuthProvider>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = authProvider.isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'กำลังเข้าสู่ระบบ...',
      child: Scaffold(
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
                      const SizedBox(height: 36),

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

                      // ✅ directly watches authProvider.errorMessage — no flag needed
                      if (authProvider.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 16,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'เบอร์โทรศัพท์หรือรหัสผ่านไม่ถูกต้อง',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: isLoading
                              ? null
                              : () => _handleLogin(authProvider),
                          child: Text(
                            'เข้าสู่ระบบ',
                            style: textTheme.labelLarge?.copyWith(
                              fontSize: 20,
                              color: Colors.white,
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
                      const Text('ยังไม่มีบัญชีใช่ไหม?'),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        ),
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
      ),
    );
  }
}