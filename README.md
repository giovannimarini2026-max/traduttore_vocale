# Traduttore Vocale

App Flutter per Android che traduce frasi dall'italiano all'inglese.

## Funzionalità

- Inserimento testo in italiano da tastiera o dettatura vocale (microfono).
- Traduzione italiano → inglese on-device tramite Google ML Kit (funziona offline dopo il primo download dei modelli, nessuna API key richiesta).
- Pronuncia della traduzione in inglese tramite sintesi vocale (text-to-speech).

## Stack tecnico

- [speech_to_text](https://pub.dev/packages/speech_to_text) — riconoscimento vocale
- [google_mlkit_translation](https://pub.dev/packages/google_mlkit_translation) — traduzione on-device
- [flutter_tts](https://pub.dev/packages/flutter_tts) — sintesi vocale

## Sviluppo

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter analyze
flutter test
```
