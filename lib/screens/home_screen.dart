import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/translation_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final TranslationService _translationService = TranslationService();
  final TextEditingController _italianController = TextEditingController();

  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isPreparingModels = true;
  bool _isTranslating = false;
  String _englishText = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('en-US');
    _initSpeech();
    _prepareTranslationModels();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (error) {
        if (!mounted) return;
        setState(() => _errorMessage = error.errorMsg);
      },
    );
    if (!mounted) return;
    setState(() => _speechAvailable = available);
  }

  Future<void> _prepareTranslationModels() async {
    try {
      await _translationService.ensureModelsDownloaded();
    } catch (e) {
      if (!mounted) return;
      setState(
        () =>
            _errorMessage = 'Impossibile scaricare i modelli di traduzione: $e',
      );
    } finally {
      if (mounted) setState(() => _isPreparingModels = false);
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      setState(
        () => _errorMessage =
            'Riconoscimento vocale non disponibile su questo dispositivo.',
      );
      return;
    }
    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
      return;
    }
    setState(() {
      _errorMessage = null;
      _isListening = true;
    });
    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() => _italianController.text = result.recognizedWords);
        if (result.finalResult) {
          setState(() => _isListening = false);
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: 'it_IT',
        partialResults: true,
      ),
    );
  }

  Future<void> _translate() async {
    final text = _italianController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _isTranslating = true;
      _errorMessage = null;
    });
    try {
      final translated = await _translationService.translate(text);
      if (!mounted) return;
      setState(() => _englishText = translated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Traduzione non riuscita: $e');
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  Future<void> _speakEnglish() async {
    if (_englishText.isEmpty) return;
    await _tts.speak(_englishText);
  }

  void _clearText() {
    setState(() {
      _italianController.clear();
      _englishText = '';
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _translationService.close();
    _italianController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Traduttore Vocale IT → EN')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isPreparingModels)
                const LinearProgressIndicator()
              else if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Text('Italiano', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Expanded(
                child: TextField(
                  controller: _italianController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Scrivi una frase o usa il microfono...',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      color: _isListening ? Colors.red : null,
                      onPressed: _toggleListening,
                      tooltip: _isListening
                          ? 'Ferma ascolto'
                          : 'Detta in italiano',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isTranslating || _isPreparingModels
                          ? null
                          : _translate,
                      icon: _isTranslating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.translate),
                      label: const Text('Traduci'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _clearText,
                    icon: const Icon(Icons.clear),
                    label: const Text('Cancella'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Inglese', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(_englishText),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _englishText.isEmpty ? null : _speakEnglish,
                icon: const Icon(Icons.volume_up),
                label: const Text('Pronuncia in inglese'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
