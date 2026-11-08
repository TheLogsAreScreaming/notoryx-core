import 'package:llamadart/llamadart.dart';

/// Whether this build can run a downloaded translation model. The lite
/// build (tool/lite) replaces this file with one that has no model runtime.
const bool kTranslationLlmAvailable = true;

/// Runs a downloaded translation model on the device, one at a time.
class TranslationLlm {
  LlamaEngine? _engine;

  /// Loads the model at [modelPath] on the CPU.
  Future<void> load(String modelPath) async {
    final engine = LlamaEngine(LlamaBackend());
    try {
      await engine.loadModel(
        modelPath,
        modelParams: const ModelParams(
          gpuLayers: 0,
          preferredBackend: GpuBackend.cpu,
        ),
      );
      _engine = engine;
    } catch (_) {
      await engine.dispose();
      rethrow;
    }
  }

  /// Streams the model's reply to [instruction].
  Stream<String> generate(
    String instruction, {
    String? sourceLanguageCode,
    required String targetLanguageCode,
  }) async* {
    final engine = _engine;
    if (engine == null) return;
    await for (final chunk in engine.create(
      [LlamaChatMessage.fromText(role: LlamaChatRole.user, text: instruction)],
      params: const GenerationParams(
        maxTokens: 256,
        temp: 0.7,
        topK: 20,
        topP: 0.6,
        penalty: 1.05,
        reusePromptPrefix: false,
      ),
      enableThinking: false,
      sourceLangCode: sourceLanguageCode,
      targetLangCode: targetLanguageCode,
    )) {
      final content = chunk.choices.firstOrNull?.delta.content;
      if (content != null) yield content;
    }
  }

  Future<void> dispose() async {
    final engine = _engine;
    _engine = null;
    await engine?.dispose();
  }
}
