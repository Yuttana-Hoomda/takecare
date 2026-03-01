import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:takecare/features/medication_alarm_overlay/models/medication_alarm_model.dart';
import 'package:takecare/features/medication_alarm_overlay/screens/medication_alarm_screen.dart';
import 'package:takecare/constants/app_theme.dart';

// ─── Config ────────────────────────────────────────────────────────────────────
// ✅ ใส่ค่าจริงตรงนี้ก่อน test
const _firebaseApiKey = 'AIzaSyDEhapjIuLKO4QGh71J-YYJa3CPKz6VuQw';
const _testPhone = '123456789'; // เบอร์ user ที่มีใน Firebase
const _testPassword = '12345678'; // password ของ user นั้น
const _realTaskId = 'gnO4QFtf5BHLTa17JaDG'; // doc id จาก Firestore > tasks
// ──────────────────────────────────────────────────────────────────────────────

http.Client createDevClient() {
  final httpClient = HttpClient()
    ..badCertificateCallback = (_, __, ___) => true;
  return IOClient(httpClient);
}

void main() {
  runApp(const TestMedicationAlarmApp());
}

class TestMedicationAlarmApp extends StatelessWidget {
  const TestMedicationAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // ✅ เพิ่มตรงนี้
      home: _TestLoader(),
    );
  }
}

class _TestLoader extends StatefulWidget {
  @override
  State<_TestLoader> createState() => _TestLoaderState();
}

class _TestLoaderState extends State<_TestLoader> {
  String? _token;
  String? _error;

  @override
  void initState() {
    super.initState();
    _login();
  }

  Future<void> _login() async {
    setState(() {
      _error = null;
      _token = null;
    });
    final client = createDevClient(); // ✅ ใช้ dev client
    try {
      final email = '$_testPhone@takecare.com';
      final res = await client.post(
        Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_firebaseApiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': _testPassword,
          'returnSecureToken': true,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _token = data['idToken'] as String);
      } else {
        final err = jsonDecode(res.body);
        setState(() => _error = err['error']['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _login, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    if (_token == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('กำลัง login...'),
            ],
          ),
        ),
      );
    }

    return MedicationAlarmScreen(
      firebaseToken: _token,
      alarm: const MedicationAlarmModel(
        id: _realTaskId,
        medicationName: 'Calcium & Vitamin D',
        scheduledTime: '8:00 AM',
        dosage: '1 tablet',
      ),
    );
  }
}
