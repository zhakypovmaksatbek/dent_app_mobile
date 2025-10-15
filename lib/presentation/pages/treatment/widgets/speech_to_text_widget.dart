import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/localization/app_localization.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/utils/speech_to_text_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SpeechToTextWidget extends StatefulWidget {
  const SpeechToTextWidget({
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
  State<SpeechToTextWidget> createState() => _SpeechToTextWidgetState();
}

class _SpeechToTextWidgetState extends State<SpeechToTextWidget>
    with TickerProviderStateMixin {
  late final SpeechToTextController _speechController;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _speechController = SpeechToTextController();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize speech recognition
    _speechController.initialize();

    // Listen to speech controller changes
    _speechController.addListener(_onSpeechStateChanged);
  }

  @override
  void dispose() {
    // Remove listener before disposing to prevent callbacks
    _speechController.removeListener(_onSpeechStateChanged);

    // Dispose animation controller
    _animationController.dispose();

    // Dispose speech controller last
    _speechController.dispose();

    super.dispose();
  }

  void _onSpeechStateChanged() {
    if (!mounted) return; // Don't update if widget is not mounted

    if (_speechController.isListening) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
      _animationController.reset();
    }
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

  Future<void> _toggleListening() async {
    if (_speechController.isListening) {
      await _speechController.stopListening();
    } else {
      await _speechController.startListening(
        onResult: widget.onResult,
        localeId: _getLocaleId(),
      );

      // If permission was denied, show the error dialog
      if (mounted &&
          _speechController.speechState == SpeechState.permissionDenied) {
        await _showErrorDialog();
      }
    }
  }

  Future<void> _showErrorDialog() async {
    if (!mounted) return; // Don't show dialog if widget is not mounted

    final speechState = _speechController.speechState;

    String title;
    String content;
    List<Widget> actions = [];

    if (speechState == SpeechState.permissionDenied) {
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
            // Try to reinitialize which will show system permission dialog
            final success = await _speechController.initialize();
            if (success && mounted) {
              // If successful, automatically try to start listening
              _toggleListening();
            }
          },
          child: Text(LocaleKeys.buttons_try_again.tr()),
        ),
      ];
    } else if (speechState == SpeechState.notAvailable) {
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
          child: Text(LocaleKeys.buttons_ok.tr()),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final success = await _speechController.initialize();
            if (success && mounted) {
              _toggleListening();
            }
          },
          child: Text(LocaleKeys.buttons_retry.tr()),
        ),
      ];
    } else {
      title = LocaleKeys.diagnosis_speech_recognition_error.tr();
      content = _speechController.errorMessage;

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
                  speechState == SpeechState.permissionDenied
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _speechController,
      builder: (context, child) {
        final theme = Theme.of(context);
        final speechState = _speechController.speechState;

        // Determine button color and icon based on state
        Color buttonColor;
        IconData iconData;

        switch (speechState) {
          case SpeechState.ready:
          case SpeechState.stopped:
            buttonColor = widget.color ?? theme.primaryColor;
            iconData = Icons.mic;
            break;
          case SpeechState.listening:
            buttonColor = Colors.red;
            iconData = Icons.mic;
            break;
          case SpeechState.error:
          case SpeechState.permissionDenied:
            buttonColor = Colors.red;
            iconData = Icons.mic_off;
            break;
          case SpeechState.notAvailable:
            buttonColor = Colors.grey;
            iconData = Icons.mic_off;
            break;
        }

        return Tooltip(
          message:
              _speechController.isListening
                  ? LocaleKeys.diagnosis_stop_recording.tr()
                  : LocaleKeys.diagnosis_start_voice_input.tr(),
          child: GestureDetector(
            onTap: () {
              if (speechState == SpeechState.error ||
                  speechState == SpeechState.permissionDenied ||
                  speechState == SpeechState.notAvailable) {
                _showErrorDialog();
              } else {
                _toggleListening();
              }
            },
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale:
                      _speechController.isListening
                          ? _scaleAnimation.value
                          : 1.0,
                  child: Container(
                    width: widget.size + 8,
                    height: widget.size + 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _speechController.isListening
                              ? buttonColor.withValues(
                                alpha: 0.1 * _pulseAnimation.value,
                              )
                              : Colors.transparent,
                    ),
                    child: Icon(
                      iconData,
                      size: widget.size,
                      color: buttonColor,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
