import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:takecare/features/link_family/models/elder_model.dart';
import 'package:takecare/features/link_family/services/link_family_service.dart';

enum LinkFamilyStatus { idle, loading, success, error }

class LinkFamilyProvider with ChangeNotifier {
  final LinkFamilyService _service = LinkFamilyService();

  LinkFamilyStatus _searchStatus = LinkFamilyStatus.idle;
  LinkFamilyStatus _linkStatus = LinkFamilyStatus.idle;

  ElderModel? _foundElder;
  String? _errorMessage;

  LinkFamilyStatus get searchStatus => _searchStatus;
  LinkFamilyStatus get linkStatus => _linkStatus;
  ElderModel? get foundElder => _foundElder;
  String? get errorMessage => _errorMessage;

  /// ค้นหา elder จากเบอร์โทร
  Future<void> searchElder(String phone, String token) async {
    _searchStatus = LinkFamilyStatus.loading;
    _errorMessage = null;
    _foundElder = null;
    notifyListeners();

    try {
      _foundElder = await _service.searchElderByPhone(phone, token);
      _searchStatus = LinkFamilyStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _searchStatus = LinkFamilyStatus.error;
      log('searchElder error: $e');
    }

    notifyListeners();
  }

  /// ยืนยัน link family
  Future<bool> confirmLink(String elderUid, String token) async {
    _linkStatus = LinkFamilyStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.linkFamily(elderUid, token);
      _linkStatus = LinkFamilyStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _linkStatus = LinkFamilyStatus.error;
      log('confirmLink error: $e');
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _searchStatus = LinkFamilyStatus.idle;
    _linkStatus = LinkFamilyStatus.idle;
    _foundElder = null;
    _errorMessage = null;
    notifyListeners();
  }
}
