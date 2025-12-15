import 'package:dent_app_mobile/core/constants/app_constants.dart';
import 'package:dent_app_mobile/core/utils/currency.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/roles.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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

  // clinic id
  Future<void> setClinicId({required int clinicId}) async {
    final prefs = await preferences();
    await prefs.setInt(AppConstants.instance.clinicId, clinicId);
  }

  Future<int?> getClinicId() async {
    final prefs = await preferences();
    final clinicId = prefs.getInt(AppConstants.instance.clinicId);
    return clinicId;
  }

  Future<bool> isTestMode() async {
    final prefs = await preferences();
    return prefs.getBool(AppConstants.instance.testModeKey) ?? false;
  }

  Future<void> setTestMode(bool isTestMode) async {
    final prefs = await preferences();
    await prefs.setBool(AppConstants.instance.testModeKey, isTestMode);
  }

  Future<void> clearTokens() async {
    final prefs = await preferences();
    await prefs.remove(AppConstants.instance.accessToken);
    await prefs.remove(AppConstants.instance.refreshToken);
    await prefs.remove(AppConstants.instance.tokenExpiry);
    await prefs.remove(AppConstants.instance.userId);
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

  Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null) return true;

    final isExpired = JwtDecoder.isExpired(token);

    if (isExpired) {
      if (kDebugMode) {
        print('⏰ Token expired or expiring soon');
      }
    }

    return isExpired;
  }

  Future<int?> getUserId() async {
    final prefs = await preferences();
    final userId = prefs.getInt(AppConstants.instance.userId);
    return userId;
  }

  Future<void> setUserId({required int userId}) async {
    final prefs = await preferences();
    await prefs.setInt(AppConstants.instance.userId, userId);
  }

  Future<Role> getRole() async {
    final prefs = await preferences();
    final role = prefs.getString(AppConstants.instance.role);
    return role != null ? Role.fromString(role) : Role.doctor;
  }

  Future<void> setRole({required Role role}) async {
    final prefs = await preferences();
    await prefs.setString(AppConstants.instance.role, role.name);
  }

  Future<void> setCurrency({required Currency currency}) async {
    final prefs = await preferences();
    await prefs.setString(AppConstants.instance.currency, currency.code);
  }

  Future<Currency> getCurrency() async {
    final prefs = await preferences();
    final currency = prefs.getString(AppConstants.instance.currency);
    return currency != null ? Currency.fromCode(currency) : Currency.som;
  }
}
