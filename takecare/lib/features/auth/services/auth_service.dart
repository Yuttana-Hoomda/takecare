import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/enum.dart';
import '../models/user_model.dart';
import 'dart:io';



// Return class ที่มีทั้ง user และ token
class LoginResult {
  final BaseUser user;
  final String token;
  LoginResult({required this.user, required this.token});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //final String baseUrl = "http://10.0.2.2:3000/api/users";
  final String baseUrl = Platform.isAndroid //เพื่อให้รันใน iphone ได้
      ? "http://10.0.2.2:3000/api/users"
      : "http://localhost:3000/api/users";

  Future<String> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? token = await result.user?.getIdToken();

      if (token != null) {
        return token;
      }
      throw Exception("Failed to generate Firebase token during registration");
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors gracefully
      if (e.code == 'email-already-in-use') {
        throw Exception("This phone number is already registered.");
      } else if (e.code == 'weak-password') {
        throw Exception("The PIN/password is too weak.");
      }
      throw Exception(e.message ?? "Registration failed");
    } catch (e) {
      log("❌ Firebase Registration failed: $e");
      rethrow;
    }
  }

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

  Future<BaseUser> createProfile({
    required String token,
    required String displayName,
    required String phoneNumber,
    Role? role,
    String profileImgUrl = '',
    String? familyId,
    List<Diseases>? ncdConditions,
    MealSchedule? foodTime,
  }) async {
    try {
      final body = {
        'displayName': displayName,
        'phoneNumber': phoneNumber,
        'profileImgUrl': profileImgUrl,
        if (role != null) 'role': role.name,
        if (familyId != null) 'familyId': familyId,
        if (ncdConditions != null)
          'ncdConditions': ncdConditions.map((e) => e.name).toList(),
        if (foodTime != null) 'foodTime': foodTime.toJson(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        log('create profile success: ${response.body}');
        final Map<String, dynamic> data = jsonDecode(response.body);
        return userFromJson(data['data']);
      } else {
        log('❌ Error [${response.statusCode}]: ${response.body}');
        throw Exception('Failed to create profile: ${response.body}');
      }
    } catch (e) {
      log('❌ createProfile error: $e');
      rethrow;
    }
  }

  Future<BaseUser> updateProfile({
    required Role role,
    required String token,
    String? displayName,
    String? phoneNumber,
    String? profileImgUrl,
    List<Diseases>? ncdConditions,
    MealSchedule? foodTime,
  }) async {
    try {
      final body = {
        // Ensure role is converted to a string or appropriate JSON format (e.g., role.name if it's an enum)
        'role': role.name,
        if (displayName != null) 'displayName': displayName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (profileImgUrl != null) 'profileImgUrl': profileImgUrl,
        if (ncdConditions != null) 'ncdConditions': ncdConditions.map((e) => e.name).toList(),
        if (foodTime != null) 'foodTime': foodTime.toJson(),
      };

      final response = await http.patch(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        log('update profile success: ${response.body}');
        final Map<String, dynamic> data = jsonDecode(response.body);
        return userFromJson(data['data']);
      } else {
        log('❌ Error [${response.statusCode}]: ${response.body}');
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      log('❌ updateProfile error: $e');
      rethrow;
    }
  }

  Future<BaseUser> fetchProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      log("  load user success: ${response.body}");
      final Map<String, dynamic> data = jsonDecode(response.body);
      return userFromJson(data['data']);
    } else {
      log("❌ Node.js Error [${response.statusCode}]: ${response.body}");
      throw Exception("Failed to fetch profile from server");
    }
  }

  // compat: เผื่อมีโค้ดเก่าที่ยังใช้ login()
  Future<BaseUser> login(String email, String password) async {
    final result = await loginWithToken(email, password);
    return result.user;
  }
}