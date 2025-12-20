// lib/core/config/environment_config.dart

import 'package:dent_app_mobile/core/constants/app_constants.dart';
import 'package:dent_app_mobile/core/manager/test_mode_manager.dart';
import 'package:flutter/foundation.dart';

enum Environment { prod, test }

class EnvironmentConfig {
  // ✅ Singleton pattern
  static final EnvironmentConfig _instance = EnvironmentConfig._internal();
  factory EnvironmentConfig() => _instance;
  EnvironmentConfig._internal();

  // ✅ Listeners for URL changes
  final List<VoidCallback> _listeners = [];

  static Environment get currentEnvironment {
    if (kTestMode) return Environment.test;
    return Environment.prod;
  }

  static final Map<Environment, String> _urls = {
    Environment.prod: AppConstants.instance.baseUrlProd,
    Environment.test: AppConstants.instance.baseUrlTest,
  };

  static String get baseUrl => _urls[currentEnvironment]!;

  // ✅ Helper getters
  static bool get isProd => currentEnvironment == Environment.prod;
  static bool get isTest => currentEnvironment == Environment.test;

  // ✅ Debug info
  static String get environmentName {
    switch (currentEnvironment) {
      case Environment.prod:
        return '🚀 Production';
      case Environment.test:
        return '🧪 Test';
    }
  }

  // ✅ NEW: Add listener for environment changes
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  // ✅ NEW: Notify listeners when environment changes
  void notifyEnvironmentChanged() {
    if (kDebugMode) {
      printConfig();
    }
    for (final listener in _listeners) {
      listener();
    }
  }

  // ✅ Print current configuration
  static void printConfig() {
    if (kDebugMode) {
      print('═══════════════════════════════════════');
      print('Environment: $environmentName');
      print('═══════════════════════════════════════');
      print('Base URL:    $baseUrl');
      print('═══════════════════════════════════════');
    }
  }
}
