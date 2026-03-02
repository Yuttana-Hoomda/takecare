import 'dart:developer';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  String? _firebaseToken; // เก็บ token ไว้ใช้กับ API

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  String? get firebaseToken => _firebaseToken;

  bool get isAuthenticated => _user != null;

  Future<void> signIn(String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final email = "$phone@takecare.com";

    try {
      final result = await _authService.loginWithToken(email, password);
      _user = result.user;
      _firebaseToken = result.token;
    } catch (e) {
      _errorMessage = "Login failed. Please check your credentials.";
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh user profile หลัง link family สำเร็จ (เพื่ออัปเดต familyId)
  Future<void> refreshUser() async {
    if (_firebaseToken == null) return;
    try {
      _user = await _authService.fetchProfile(_firebaseToken!);
      notifyListeners();
    } catch (e) {
      log('refreshUser error: $e');
    }
  }

  void logout() {
    _user = null;
    _firebaseToken = null;
    notifyListeners();
  }
}