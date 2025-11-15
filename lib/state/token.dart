import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
class TokenRepository {
  static const _keyToken = "access_token";
  static const _keyInstance = "instance_url";

  /// simpan access token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  /// ambil access token
  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// hapus access token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  /// simpan instance/server URL
  Future<void> saveInstanceUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyInstance, url);
  }

  /// ambil instance/server URL
  Future<String?> loadInstanceUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyInstance);
  }

  /// hapus instance URL
  Future<void> clearInstanceUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyInstance);
  }

  /// clear semua auth
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyInstance);
  }
}

final tokenRepoProvider = Provider((ref) => TokenRepository());

/// provider hanya untuk token
final tokenProvider = FutureProvider<String?>((ref) async {
  return ref.read(tokenRepoProvider).loadToken();
});

/// provider hanya untuk instance_url
final instanceUrlProvider = FutureProvider<String?>((ref) async {
  return ref.read(tokenRepoProvider).loadInstanceUrl();
});