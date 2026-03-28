import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../constants/enum.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  BaseUser? _user;
  String? _firebaseToken; // เก็บ token ไว้ใช้กับ API

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BaseUser? get user => _user;
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

  Future<bool> createInitialUser(String name, String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final email = "$phone@takecare.com";
      // 1. Create Firebase Auth
      _firebaseToken = await _authService.registerWithEmail(email, password);

      // 2. Call Node.js POST /profile (Backend MUST be updated to allow null role)
      _user = await _authService.createProfile(
        token: _firebaseToken!,
        displayName: name,
        phoneNumber: phone,
        role: Role.pending,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRoleToCaregiver() async {
    if (_firebaseToken == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      // Call Node.js PATCH /profile
      _user = await _authService.updateProfile(
        token: _firebaseToken!,
        role: Role.caregiver,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateElderProfile({
    required List<Diseases> ncdConditions,
    required MealSchedule foodTime,
  }) async {
    if (_firebaseToken == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      // Call Node.js PATCH /profile
      _user = await _authService.updateProfile(
        token: _firebaseToken!,
        role: Role.elder,
        ncdConditions: ncdConditions,
        foodTime: foodTime,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProfile({
    required String displayName,
    required String phoneNumber,
    String profileImgUrl = '',
    String? familyId,
    List<Diseases>? ncdConditions,
    MealSchedule? foodTime,
  }) async {
    if (_firebaseToken == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.createProfile(
        token: _firebaseToken!,
        displayName: displayName,
        phoneNumber: phoneNumber,
        profileImgUrl: profileImgUrl,
        familyId: familyId,
        ncdConditions: ncdConditions,
        foodTime: foodTime,
      );
    } catch (e) {
      _errorMessage = e.toString();
      log('createProfile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required Role role,
    String? displayName,
    String? phoneNumber,
    String? profileImgUrl,
    List<Diseases>? ncdConditions,
    MealSchedule? foodTime,
  }) async {
    if (_firebaseToken == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.updateProfile(
        token: _firebaseToken!,
        displayName: displayName,
        role: role,
        phoneNumber: phoneNumber,
        profileImgUrl: profileImgUrl,
        ncdConditions: ncdConditions,
        foodTime: foodTime,
      );
    } catch (e) {
      _errorMessage = e.toString();
      log('updateProfile error: $e');
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