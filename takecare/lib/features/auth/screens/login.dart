import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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

    return Scaffold(
      appBar: AppBar(title: const Text("Takecare Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            authProvider.isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final phone = phoneController.text.trim();
                        final pass = passwordController.text.trim();

                        // --- DEBUG START ---
                        debugPrint("======= 🔘 LOGIN BUTTON PRESSED =======");
                        debugPrint("📍 Phone input: '$phone'");
                        debugPrint("📍 Password input length: ${pass.length}");
                        // -------------------

                        try {
                          await authProvider.signIn(phone, pass);

                          // --- DEBUG AFTER SIGNIN ---
                          debugPrint("======= 🔍 AFTER signIn() CALL =======");
                          debugPrint(
                            "📍 Provider isAuthenticated: ${authProvider.isAuthenticated}",
                          );
                          debugPrint(
                            "📍 Provider user object: ${authProvider.user}",
                          );

                          if (authProvider.isAuthenticated) {
                            debugPrint("  LOGIN SUCCESS: User found!");
                          } else {
                            debugPrint(
                              "⚠️ LOGIN FINISHED: But user is still null (check provider logic)",
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "เข้าสู่ระบบไม่สำเร็จ: ไม่พบข้อมูลผู้ใช้",
                                ),
                              ),
                            );
                          }
                          debugPrint("======================================");
                        } catch (e) {
                          // --- DEBUG ERROR ---
                          debugPrint("🔥 CRITICAL LOGIN ERROR: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Login Failed: $e")),
                          );
                        }
                      },
                      child: const Text("เข้าสู่ระบบ"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
