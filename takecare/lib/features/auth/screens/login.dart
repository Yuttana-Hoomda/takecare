import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; //
import '../providers/auth_provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // ย้าย Controller มาไว้ใน State เพื่อความเสถียร
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

            // แสดง Loading ตามสถานะใน Provider
            authProvider.isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await authProvider.signIn(
                      phoneController.text.trim(),
                      passwordController.text.trim(),
                    );
                    Navigator() {

                    }
                  } catch (e) {
                    // แสดง Error ให้ผู้ใช้เห็น
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