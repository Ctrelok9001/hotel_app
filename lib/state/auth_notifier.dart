import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/hotel_data_store.dart';
import '../models/app_user.dart';
import '../models/role.dart';

class AuthNotifier extends ChangeNotifier {
  static const _storageKey = 'hotel_app_auth_user';

  AppUser? _user;
  bool _isInitialized = false;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  Role? get currentRole => _user?.role;
  String? get accessToken => _user?.token;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        _user = AppUser.fromJson(json);
      }
    } catch (e) {
      debugPrint('[Auth] Ошибка восстановления сессии: $e');
      _user = null;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  bool hasRole(Role minRole) {
    if (_user == null) return false;
    return _user!.role.level >= minRole.level;
  }

  bool isExactRole(Role role) {
    return _user?.role == role;
  }

  Future<void> login(String email, String password) async {
    final user = await HotelDataStore.instance.login(email, password);
    _user = user;
    await _persistUser(user);
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final user = await HotelDataStore.instance.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );
    _user = user;
    await _persistUser(user);
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }

  Future<void> refreshTokens() async {
    if (_user == null) return;
    final updated = AppUser(
      id: _user!.id,
      email: _user!.email,
      name: _user!.name,
      role: _user!.role,
      token: 'jwt_refreshed_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: _user!.refreshToken,
      guestId: _user!.guestId,
    );
    _user = updated;
    await _persistUser(updated);
    notifyListeners();
  }

  Future<void> _persistUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(user.toJson()));
  }
}
