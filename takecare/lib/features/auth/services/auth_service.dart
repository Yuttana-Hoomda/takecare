import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String baseUrl = "http://10.0.2.2:3000/api/users";
  // // ถ้าใช้ Flutter Web
  // final String baseUrl = "http://localhost:3000/api/users";

  Future<User> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? token = await result.user?.getIdToken();

      if (token != null) {
        final response = await http.get(
          Uri.parse('$baseUrl/profile'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          log("✅ load user success: ${response.body}");

          final Map<String, dynamic> data = jsonDecode(response.body);
          return User.fromJson(data['data']);
        } else {
          log("❌ Node.js Error [${response.statusCode}]: ${response.body}");
          throw Exception("Failed to fetch profile from server");
        }
      }
      throw Exception("Failed to get Firebase token");
    } catch (e) {
      log("failed: $e");
      rethrow;
    }
  }
}
