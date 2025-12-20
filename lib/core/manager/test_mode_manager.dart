// lib/core/manager/test_mode_manager.dart

import 'package:dent_app_mobile/core/config/environment_config.dart';
import 'package:dent_app_mobile/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestModeManager {
  static final TestModeManager _instance = TestModeManager._internal();
  factory TestModeManager() => _instance;
  TestModeManager._internal();

  static const int _requiredTaps = 5;
  static const Duration _tapTimeout = Duration(seconds: 3);

  bool _isTestMode = false;
  DateTime? _lastTapTime;
  int _tapCount = 0;
  bool _wasTestMode = false;

  bool get kTestMode => _isTestMode;
  int get tapCount => _tapCount;
  bool get stateChanged => _wasTestMode != _isTestMode;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isTestMode = prefs.getBool(AppConstants.instance.testModeKey) ?? false;
    _wasTestMode = _isTestMode;
    debugPrint('🧪 Test Mode: ${_isTestMode ? "ENABLED" : "DISABLED"}');
  }

  Future<bool> handleTap() async {
    final now = DateTime.now();

    if (_lastTapTime != null && now.difference(_lastTapTime!) > _tapTimeout) {
      _tapCount = 0;
    }

    _lastTapTime = now;
    _tapCount++;

    debugPrint('🔘 Test mode tap: $_tapCount/$_requiredTaps');

    if (_tapCount >= _requiredTaps) {
      _wasTestMode = _isTestMode;
      await _toggleTestMode();
      _tapCount = 0;
      _lastTapTime = null;
      return true;
    }

    return false;
  }

  Future<void> _toggleTestMode() async {
    _isTestMode = !_isTestMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.instance.testModeKey, _isTestMode);

    debugPrint('🧪 Test Mode ${_isTestMode ? "ENABLED ✅" : "DISABLED ❌"}');

    // ✅ Notify environment change
    EnvironmentConfig().notifyEnvironmentChanged();
  }

  Future<void> setTestMode(bool enabled) async {
    _wasTestMode = _isTestMode;
    _isTestMode = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.instance.testModeKey, enabled);

    debugPrint(
      '🧪 Test Mode manually set to: ${_isTestMode ? "ENABLED" : "DISABLED"}',
    );

    // ✅ Notify environment change
    EnvironmentConfig().notifyEnvironmentChanged();
  }

  void resetTapCounter() {
    _tapCount = 0;
    _lastTapTime = null;
    _wasTestMode = _isTestMode;
  }
}

// Global getter
bool get kTestMode => TestModeManager().kTestMode;
