import 'dart:math' as math;

import 'package:dent_app_mobile/core/service/speech_recognition_service.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/localization/app_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

enum _SpeechState { idle, listening, permissionDenied, notAvailable, error }

class NewSpeechToTextWidget extends StatefulWidget {
  const NewSpeechToTextWidget({
    super.key,
    required this.onResult,
    this.localeId,
    this.size = 24.0,
    this.color,
  });
  final Function(String) onResult;
  final String? localeId;
  final double size;
  final Color? color;
  @override
  State<NewSpeechToTextWidget> createState() => _NewSpeechToTextWidgetState();
}

class _NewSpeechToTextWidgetState extends State<NewSpeechToTextWidget>
    with TickerProviderStateMixin {
  final _speechService = SpeechRecognitionService();

  // Animasyon kontrolcüleri
  late final AnimationController _animationController;
  late final AnimationController _rotationController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _wave1Animation;
  late final Animation<double> _wave2Animation;
  late final Animation<double> _wave3Animation;

  // Widget'ın kendi yerel durumu
  _SpeechState _currentState = _SpeechState.idle;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Pulse animasyonu - ana ikon için
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Dönen border animasyonu
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Dalga animasyonları - her biri farklı delay ve hızda
    _wave1Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
    _wave2Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    _wave3Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  // Kullanıcı mikrofona bastığında çalışacak ana metot
  Future<void> _toggleListening() async {
    // Eğer dinliyorsa, durdur ve çık
    if (_speechService.isListening) {
      await _speechService.stopListening();
      return;
    }

    // İlk kez basıldığında veya izin durumu bilinmediğinde servisi başlat
    // Bu, izin isteme diyaloğunu tetikleyecek
    final isInitialized = await _speechService.initialize();
    if (!isInitialized && mounted) {
      // İzin durumunu kontrol et
      final microphoneStatus = await Permission.microphone.status;

      if (microphoneStatus.isDenied ||
          microphoneStatus.isPermanentlyDenied ||
          microphoneStatus.isRestricted) {
        setState(() => _currentState = _SpeechState.permissionDenied);
      } else {
        setState(() => _currentState = _SpeechState.notAvailable);
      }
      _showErrorDialog();
      return;
    }

    // Servis başlatıldıktan sonra dinlemeyi başlat
    await _speechService.startListening(
      onResult: _onSpeechResult,
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
      localeId: _getLocaleId(),
    );
  }

  // --- Callback Metotları ---
  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult && result.recognizedWords.isNotEmpty) {
      widget.onResult(result.recognizedWords);
    }
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;
    setState(() {
      switch (status) {
        case 'listening':
          _currentState = _SpeechState.listening;
          _animationController.repeat(reverse: true);
          _rotationController.repeat();
          break;
        case 'notListening':
        case 'done':
          _currentState = _SpeechState.idle;
          _animationController.stop();
          _animationController.reset();
          _rotationController.stop();
          _rotationController.reset();
          break;
      }
    });
  }

  void _onSpeechError(dynamic error) {
    if (!mounted) return;

    final errorStr = error.toString().toLowerCase();
    _SpeechState newState;

    if (errorStr.contains('permission')) {
      newState = _SpeechState.permissionDenied;
    } else if (errorStr.contains('not_available')) {
      newState = _SpeechState.notAvailable;
    } else {
      newState = _SpeechState.error;
      _errorMessage = error.toString();
    }

    setState(() {
      _currentState = newState;
      _animationController.stop();
      _animationController.reset();
      _rotationController.stop();
      _rotationController.reset();
    });

    // Hata oluştuğunda hemen diyalog göster
    _showErrorDialog();
  }

  String _getLocaleId() {
    if (widget.localeId != null) {
      return widget.localeId!;
    }

    // Get current app locale
    final currentLocale = AppLocalization.getCurrentLanguageCode(context);

    // Map common locales to speech recognition locale IDs
    switch (currentLocale) {
      case 'ru':
        return 'ru_RU';
      case 'en':
        return 'en_US';
      case 'tr':
        return 'tr_TR';
      case 'ky':
        return 'ky_KG';
      default:
        return 'en_US'; // Default fallback
    }
  }

  Future<void> _showErrorDialog() async {
    if (!mounted) return; // Don't show dialog if widget is not mounted

    final speechState = _currentState;

    String title;
    String content;
    List<Widget> actions = [];

    if (speechState == _SpeechState.permissionDenied) {
      title = LocaleKeys.diagnosis_microphone_permission_required.tr();
      content =
          LocaleKeys.diagnosis_microphone_permission_required_description.tr();

      actions = [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          child: Text(LocaleKeys.buttons_cancel.tr()),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();
            // Kullanıcıyı uygulama ayarlarına yönlendir
            await openAppSettings();
          },
          child: Text(LocaleKeys.routes_settings.tr()),
        ),
      ];
    } else if (speechState == _SpeechState.notAvailable) {
      title = LocaleKeys.diagnosis_speech_recognition_not_available.tr();
      content =
          LocaleKeys.diagnosis_speech_recognition_not_available_description
              .tr();

      actions = [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          child: Text(LocaleKeys.buttons_cancel.tr()),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final success = await _speechService.initialize();
            if (success && mounted) {
              _toggleListening();
            }
          },
          child: Text(LocaleKeys.buttons_retry.tr()),
        ),
      ];
    } else {
      title = LocaleKeys.diagnosis_speech_recognition_error.tr();
      content = _errorMessage;

      actions = [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocaleKeys.buttons_ok.tr()),
        ),
      ];
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  speechState == _SpeechState.permissionDenied
                      ? Icons.mic_off
                      : Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title)),
              ],
            ),
            content: Text(content),
            actions: actions,
          ),
    );
  }

  Widget _buildWaveRing(double scale, double opacity) {
    final theme = Theme.of(context);
    final iconColor =
        _currentState == _SpeechState.listening
            ? Colors.red
            : widget.color ?? theme.primaryColor;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size + 16,
        height: widget.size + 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: iconColor.withValues(alpha: opacity),
            width: 2.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData iconData;
    String tooltipMessage;

    // Duruma göre ikon ve tooltip belirle
    switch (_currentState) {
      case _SpeechState.listening:
        iconData = Icons.mic;
        tooltipMessage = LocaleKeys.diagnosis_stop_recording.tr();
        break;
      case _SpeechState.permissionDenied:
      case _SpeechState.notAvailable:
      case _SpeechState.error:
        iconData = Icons.mic_off;
        tooltipMessage = LocaleKeys.diagnosis_start_voice_input.tr();
        break;
      case _SpeechState.idle:
        iconData = Icons.mic;
        tooltipMessage = LocaleKeys.diagnosis_start_voice_input.tr();
        break;
    }

    // Renk mantığı: Her zaman primary, dinlerken kırmızı
    final iconColor =
        _currentState == _SpeechState.listening
            ? Colors.red
            : widget.color ?? theme.primaryColor;

    return Tooltip(
      message: tooltipMessage,
      child: GestureDetector(
        onTap: _toggleListening,
        child: SizedBox(
          width: widget.size + 16,
          height: widget.size + 16,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none, // Animasyonların dışarı taşmasına izin ver
            children: [
              // Dalga efektleri - sadece dinleme sırasında görünür
              if (_currentState == _SpeechState.listening) ...[
                AnimatedBuilder(
                  animation: _wave1Animation,
                  builder: (context, child) {
                    return _buildWaveRing(
                      1.0 + _wave1Animation.value * 1.5,
                      (1.0 - _wave1Animation.value) * 0.6,
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _wave2Animation,
                  builder: (context, child) {
                    return _buildWaveRing(
                      1.0 + _wave2Animation.value * 1.5,
                      (1.0 - _wave2Animation.value) * 0.6,
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _wave3Animation,
                  builder: (context, child) {
                    return _buildWaveRing(
                      1.0 + _wave3Animation.value * 1.5,
                      (1.0 - _wave3Animation.value) * 0.6,
                    );
                  },
                ),
              ],

              // Dönen border - sadece dinleme sırasında
              if (_currentState == _SpeechState.listening)
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * math.pi,
                      child: Container(
                        width: widget.size + 12,
                        height: widget.size + 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.transparent,
                            width: 3,
                          ),
                          gradient: SweepGradient(
                            colors: [
                              iconColor.withValues(alpha: 0.0),
                              iconColor.withValues(alpha: 0.9),
                              iconColor.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Ana mikrofon ikonu
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale:
                        _currentState == _SpeechState.listening
                            ? _pulseAnimation.value
                            : 1.0,
                    child: Container(
                      width: widget.size + 8,
                      height: widget.size + 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentState == _SpeechState.listening
                                ? iconColor.withValues(alpha: 0.2)
                                : Colors.transparent,
                        boxShadow:
                            _currentState == _SpeechState.listening
                                ? [
                                  BoxShadow(
                                    color: iconColor.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                                : null,
                      ),
                      child: Icon(
                        iconData,
                        size: widget.size,
                        color: iconColor,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
