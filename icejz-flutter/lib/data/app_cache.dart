import 'dart:convert';

import 'package:icejz_app/data/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppCache {
  AppCache(this._prefs);

  final SharedPreferences _prefs;

  static const _keyToken = 'token';
  static const _keyUser = 'userInfo';
  static const _keyGuide = 'icejz_guide_done';

  static Future<AppCache> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppCache(prefs);
  }

  Future<void> setToken(String token) => _prefs.setString(_keyToken, token);

  String? getToken() {
    final v = _prefs.getString(_keyToken);
    if (v == null || v.trim().isEmpty) return null;
    return v;
  }

  Future<void> removeToken() => _prefs.remove(_keyToken);

  Future<void> setUserInfo(UserInfo user) =>
      _prefs.setString(_keyUser, jsonEncode(user.toJson()));

  UserInfo? getUserInfo() {
    final raw = _prefs.getString(_keyUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserInfo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> removeUserInfo() => _prefs.remove(_keyUser);

  Future<void> clear() => _prefs.clear();

  Future<void> set(String key, String value) => _prefs.setString(key, value);

  String? get(String key) => _prefs.getString(key);

  Future<void> remove(String key) => _prefs.remove(key);

  bool isGuideDone() => _prefs.getString(_keyGuide) == '1';

  Future<void> markGuideDone() => _prefs.setString(_keyGuide, '1');

  Future<void> clearGuideDone() => _prefs.remove(_keyGuide);
}
