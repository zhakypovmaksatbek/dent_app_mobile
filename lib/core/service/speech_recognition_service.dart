import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechRecognitionService {
  static final SpeechRecognitionService _instance =
      SpeechRecognitionService._internal();
  factory SpeechRecognitionService() => _instance;
  SpeechRecognitionService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  // Callback'leri sakla
  Function(String)? _onStatus;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speechToText.initialize();
    return _isInitialized;
  }

  bool get isListening => _speechToText.isListening;

  Future<void> startListening({
    required Function(SpeechRecognitionResult) onResult,
    required Function(String) onStatus,
    required Function(dynamic) onError,
    String? localeId,
  }) async {
    try {
      // Callback'i sakla
      _onStatus = onStatus;

      if (!await initialize()) {
        onError('not_available');
        return;
      }

      // Dinlemeye başlamadan önce "listening" status'ü gönder
      onStatus('listening');

      await _speechToText.listen(
        onResult: (result) {
          // Her result'ta kontrol et: eğer dinleme durmuşsa status güncelle
          onResult(result);

          // Final result geldiğinde veya dinleme durduğunda "done" status'ü gönder
          if (result.finalResult || !_speechToText.isListening) {
            onStatus('done');
          }
        },
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
        ),
      );

      // Listen metodu tamamlandığında (otomatik durdurma)
      // Eğer hala dinleme durumu varsa, "done" status'ü gönder
      if (!_speechToText.isListening) {
        onStatus('done');
      }
    } catch (e) {
      onStatus('notListening');
      onError(e);
    }
  }

  Future<void> stopListening() async {
    if (!_isInitialized) return;
    await _speechToText.stop();

    // Durdurulduğunda "notListening" status'ü gönder
    _onStatus?.call('notListening');
  }
}
