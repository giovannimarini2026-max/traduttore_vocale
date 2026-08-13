import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// Traduce testo dall'italiano all'inglese usando i modelli ML Kit
/// scaricati sul dispositivo (funziona offline dopo il primo download).
class TranslationService {
  final OnDeviceTranslator _translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.italian,
    targetLanguage: TranslateLanguage.english,
  );

  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  Future<void> ensureModelsDownloaded() async {
    for (final language in [TranslateLanguage.italian, TranslateLanguage.english]) {
      final isDownloaded = await _modelManager.isModelDownloaded(language.bcpCode);
      if (!isDownloaded) {
        await _modelManager.downloadModel(language.bcpCode);
      }
    }
  }

  Future<String> translate(String text) async {
    return _translator.translateText(text);
  }

  void close() {
    _translator.close();
  }
}
