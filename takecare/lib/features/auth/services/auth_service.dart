import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

// Return class ที่มีทั้ง user และ token
class LoginResult {
  final User user;
  final String token;
  LoginResult({required this.user, required this.token});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String baseUrl = "http://10.0.2.2:3000/api/users";
  // final String baseUrl = "http://localhost:3000/api/users"; // Flutter Web

  Future<LoginResult> loginWithToken(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? token = await result.user?.getIdToken();

      if (token != null) {
        final user = await fetchProfile(token);
        return LoginResult(user: user, token: token);
      }
      throw Exception("Failed to get Firebase token");
    } catch (e) {
      log("failed: $e");
      rethrow;
    }
  }

  Future<User> fetchProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      log("  load user success: ${response.body}");
      final Map<String, dynamic> data = jsonDecode(response.body);
      return User.fromJson(data['data']);
    } else {
      log("❌ Node.js Error [${response.statusCode}]: ${response.body}");
      throw Exception("Failed to fetch profile from server");
    }
  }

  // compat: เผื่อมีโค้ดเก่าที่ยังใช้ login()
  Future<User> login(String email, String password) async {
    final result = await loginWithToken(email, password);
    return result.user;
  }
}
