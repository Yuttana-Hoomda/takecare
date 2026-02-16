import 'dart:developer';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  bool get isAuthenticated => _user != null;

  Future<void> signIn(String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final email = "$phone@takecare.com";

    try {
      _user = await _authService.login(email, password);

    } catch (e) {
      _errorMessage = "Login failed. Please check your credentials.";
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 6. ADD LOGOUT
  void logout() {
    _user = null;
    notifyListeners(); // Kicks the user back to the Login Screen
  }
}