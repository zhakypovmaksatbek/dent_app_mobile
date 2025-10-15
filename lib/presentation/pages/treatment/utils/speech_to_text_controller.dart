import 'dart:async';

import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum SpeechState {
  ready,
  listening,
  stopped,
  error,
  permissionDenied,
  notAvailable,
}

class SpeechToTextController extends ChangeNotifier {
  // Speech to Text instance
  final SpeechToText _speechToText = SpeechToText();

  // State variables
  SpeechState _speechState = SpeechState.ready;
  String _lastWords = '';
  String _errorMessage = '';
  bool _isInitialized = false;
  double _confidenceLevel = 0.0;
  Timer? _listeningTimer;
  bool _disposed = false;

  // Configuration
  static const Duration _listeningTimeout = Duration(seconds: 30);
  static const Duration _pauseTimeout = Duration(seconds: 3);

  // Getters
  SpeechState get speechState => _speechState;
  String get lastWords => _lastWords;
  String get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get isListening => _speechState == SpeechState.listening;
  bool get isAvailable =>
      _isInitialized && _speechState != SpeechState.notAvailable;
  double get confidenceLevel => _confidenceLevel;

  // Initialize speech recognition
  Future<bool> initialize() async {
    try {
      // Reset error state before initialization
      _errorMessage = '';

      // Let speech_to_text handle its own permission
      final bool available = await _speechToText.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
        debugLogging: false,
      );

      if (available) {
        _isInitialized = true;
        _updateState(SpeechState.ready);
        return true;
      } else {
        // Check if it's a permission issue
        final hasPermission = await _speechToText.hasPermission;
        if (!hasPermission) {
          _updateState(SpeechState.permissionDenied);
          _errorMessage =
              LocaleKeys.diagnosis_microphone_permission_required_description
                  .tr();
        } else {
          _updateState(SpeechState.notAvailable);
          _errorMessage =
              LocaleKeys.errors_speech_recognition_not_available.tr();
        }
        return false;
      }
    } catch (e) {
      _updateState(SpeechState.error);
      _errorMessage = 'Failed to initialize speech recognition: $e';
      return false;
    }
  }

  // Start listening
  Future<void> startListening({
    Function(String)? onResult,
    String? localeId,
  }) async {
    // Initialize if not already done
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    // Check permission before attempting to listen
    final hasPermission = await _speechToText.hasPermission;
    if (!hasPermission) {
      _updateState(SpeechState.permissionDenied);
      _errorMessage =
          LocaleKeys.diagnosis_microphone_permission_required_description.tr();
      return;
    }

    if (!isAvailable || isListening) return;

    try {
      _lastWords = '';
      _confidenceLevel = 0.0;
      _errorMessage = '';

      await _speechToText.listen(
        onResult: (result) => _onSpeechResult(result, onResult),
        listenFor: _listeningTimeout,
        pauseFor: _pauseTimeout,
        localeId: localeId ?? 'en_US',
        cancelOnError: true,
        partialResults: true,
        listenMode: ListenMode.confirmation,
      );

      _updateState(SpeechState.listening);

      // Set a timeout to automatically stop listening
      _listeningTimer?.cancel();
      _listeningTimer = Timer(_listeningTimeout, () {
        if (isListening) {
          stopListening();
        }
      });
    } catch (e) {
      debugPrint('Error starting listening: $e');

      // Check if it's a permission error
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('permission') ||
          errorString.contains('denied') ||
          errorString.contains('not authorized')) {
        _updateState(SpeechState.permissionDenied);
        _errorMessage =
            LocaleKeys.diagnosis_microphone_permission_required_description
                .tr();
      } else {
        _updateState(SpeechState.error);
        _errorMessage = 'Failed to start listening: $e';
      }
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    if (!isListening) return;

    try {
      await _speechToText.stop();
      _listeningTimer?.cancel();
      _updateState(SpeechState.stopped);
    } catch (e) {
      _updateState(SpeechState.error);
      _errorMessage = 'Failed to stop listening: $e';
    }
  }

  // Cancel listening
  Future<void> cancelListening() async {
    if (!isListening) return;

    try {
      await _speechToText.cancel();
      _listeningTimer?.cancel();
      _lastWords = '';
      _confidenceLevel = 0.0;
      _updateState(SpeechState.ready);
    } catch (e) {
      _updateState(SpeechState.error);
      _errorMessage = 'Failed to cancel listening: $e';
    }
  }

  // Get available locales
  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _speechToText.locales();
  }

  // Handle speech result
  void _onSpeechResult(
    SpeechRecognitionResult result,
    Function(String)? onResult,
  ) {
    if (_disposed) return; // Don't process if already disposed

    _lastWords = result.recognizedWords;
    _confidenceLevel = result.confidence;

    if (result.finalResult) {
      onResult?.call(_lastWords);
      _updateState(SpeechState.stopped);
    }

    if (!_disposed) {
      notifyListeners();
    }
  }

  // Handle speech error
  void _onSpeechError(dynamic error) {
    if (_disposed) return; // Don't process if already disposed

    debugPrint('Speech error: $error');

    // Check if it's a permission error
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('permission') ||
        errorString.contains('denied') ||
        errorString.contains('not authorized')) {
      _updateState(SpeechState.permissionDenied);
      _errorMessage =
          LocaleKeys.diagnosis_microphone_permission_required_description.tr();
    } else if (errorString.contains('not available') ||
        errorString.contains('service') ||
        errorString.contains('unavailable')) {
      _updateState(SpeechState.notAvailable);
      _errorMessage = LocaleKeys.errors_speech_recognition_not_available.tr();
    } else {
      _updateState(SpeechState.error);
      _errorMessage = 'Speech recognition error: $error';
    }

    _listeningTimer?.cancel();
  }

  // Handle speech status changes
  void _onSpeechStatus(String status) {
    if (_disposed) return; // Don't process if already disposed

    debugPrint('Speech status: $status');

    switch (status) {
      case 'listening':
        _updateState(SpeechState.listening);
        break;
      case 'notListening':
        if (_speechState == SpeechState.listening) {
          _updateState(SpeechState.stopped);
        }
        break;
      case 'done':
        _updateState(SpeechState.ready);
        break;
    }
  }

  // Update state and notify listeners
  void _updateState(SpeechState newState) {
    if (_disposed) return; // Don't update if already disposed

    if (_speechState != newState) {
      _speechState = newState;
      notifyListeners();
    }
  }

  // Reset to ready state
  void reset() {
    _lastWords = '';
    _errorMessage = '';
    _confidenceLevel = 0.0;
    _listeningTimer?.cancel();
    _updateState(SpeechState.ready);
  }

  // Open app settings for permission
  Future<void> openSettings() async {
    // For speech permissions, user needs to go to device settings manually
    // We can't programmatically open speech settings
    debugPrint(
      'User should manually enable microphone permissions in device settings',
    );
  }

  @override
  void dispose() {
    _listeningTimer?.cancel();
    _disposed = true;
    super.dispose();
  }
}
