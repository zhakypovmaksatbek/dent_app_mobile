import 'package:dent_app_mobile/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDataService {
  AppDataService._();
  static AppDataService instance = AppDataService._();

  Future<SharedPreferences> preferences() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> setToken({required String accessToken}) async {
    final prefs = await preferences();
    await prefs.setString(AppConstants.instance.accessToken, accessToken);
  }

  Future<String?> getToken() async {
    final prefs = await preferences();
    final token = prefs.getString(AppConstants.instance.accessToken);
    return token;
  }

  Future<void> setRefreshToken({required String refreshToken}) async {
    final prefs = await preferences();
    await prefs.setString(AppConstants.instance.refreshToken, refreshToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await preferences();
    final refreshToken = prefs.getString(AppConstants.instance.refreshToken);
    return refreshToken;
  }

  Future<void> clearTokens() async {
    final prefs = await preferences();
    await prefs.remove(AppConstants.instance.accessToken);
    await prefs.remove(AppConstants.instance.refreshToken);
    await prefs.remove(AppConstants.instance.tokenExpiry);
    await setIsLogin(false);
  }

  Future<void> setIsLogin(bool isLogin) async {
    final prefs = await preferences();
    await prefs.setBool(AppConstants.instance.isLogin, isLogin);
  }

  Future<bool> getIsLogin() async {
    final prefs = await preferences();
    return prefs.getBool(AppConstants.instance.isLogin) ?? false;
  }

  Future<void> setTokenExpiry({required DateTime expiryTime}) async {
    final prefs = await preferences();
    await prefs.setInt(
      AppConstants.instance.tokenExpiry,
      expiryTime.millisecondsSinceEpoch,
    );
  }

  Future<DateTime?> getTokenExpiry() async {
    final prefs = await preferences();
    final expiry = prefs.getInt(AppConstants.instance.tokenExpiry);
    return expiry != null ? DateTime.fromMillisecondsSinceEpoch(expiry) : null;
  }

  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;

    final now = DateTime.now();
    final isExpired = now.isAfter(expiry.subtract(const Duration(minutes: 20)));

    if (isExpired) {
      if (kDebugMode) {
        print('⏰ Token expired or expiring soon');
        print('⏰ Current time: ${now.toIso8601String()}');
        print('⏰ Token expiry: ${expiry.toIso8601String()}');
        print('⏰ Remaining time: ${expiry.difference(now).inSeconds} seconds');
      }
    }

    return isExpired;
  }
}
