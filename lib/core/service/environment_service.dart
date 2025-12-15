// lib/core/service/environment_service.dart

import 'package:dent_app_mobile/core/constants/app_constants.dart';
import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnvironmentService {
  final AppDataService _appDataService = AppDataService.instance;
  final SharedPreferences prefs;
  EnvironmentService(this.prefs);
  Future<void> toggleTestMode() async {
    final currentMode = await _appDataService.isTestMode();
    await _appDataService.setTestMode(!currentMode);
  }

  String getBaseUrl(String prodUrl, String testUrl) {
    final isTest = prefs.getBool(AppConstants.instance.testModeKey) ?? false;
    return isTest ? testUrl : prodUrl;
  }
}
