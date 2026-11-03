import '../../../../core/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/ai_repository.dart';

class SendAiQueryUseCase {
  const SendAiQueryUseCase(this._repository);

  final AiRepository _repository;

  /// Sanitasi prompt & penerapan privacy guard sebelum query dikirim ke cloud LLM:
  /// - Mencegah token rahasia, NIK, kata sandi terkirim ke LLM (Step 4 & Step 2).
  /// - Memastikan prompt tidak kosong.
  Future<({String? response, Failure? failure, bool isOfflineFallback})> execute({
    required String rawQuestion,
    List<ChatMessage> history = const [],
  }) async {
    final trimmed = rawQuestion.trim();
    if (trimmed.isEmpty) {
      return (
        response: null,
        failure: const ValidationFailure('Pertanyaan tidak boleh kosong.'),
        isOfflineFallback: false,
      );
    }

    final sanitizedQuestion = sanitizePrivacyData(trimmed);

    return _repository.askQuestion(
      question: sanitizedQuestion,
      conversationHistory: history,
    );
  }

  Stream<String> executeStream({
    required String rawQuestion,
    List<ChatMessage> history = const [],
  }) {
    final sanitizedQuestion = sanitizePrivacyData(rawQuestion.trim());
    return _repository.streamQuestion(
      question: sanitizedQuestion,
      conversationHistory: history,
    );
  }

  static String sanitizePrivacyData(String text) {
    // Sensor nomor NIK / kartu identitas (16 digit angka)
    final nikRegex = RegExp(r'\b\d{16}\b');
    var sanitized = text.replaceAll(nikRegex, '[NIK_SENSITIF_DISENSOR]');

    // Sensor nomor telepon Indonesia jika ada (+62 atau 08xx)
    final phoneRegex = RegExp(r'(?:\b08\d{8,11}|\+62\d{9,12}\b)');
    sanitized = sanitized.replaceAll(phoneRegex, '[NO_HP_DISENSOR]');

    // Sensor token JWT atau access token jika ada
    final tokenRegex = RegExp(r'\beyJ[a-zA-Z0-9_\-\.]+\b');
    sanitized = sanitized.replaceAll(tokenRegex, '[TOKEN_AUTH_DISENSOR]');

    return sanitized;
  }
}
