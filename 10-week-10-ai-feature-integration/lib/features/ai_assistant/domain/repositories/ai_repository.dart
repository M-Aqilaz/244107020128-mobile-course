import '../../../../core/failures.dart';
import '../entities/chat_message.dart';

abstract class AiRepository {
  Future<({String? response, Failure? failure, bool isOfflineFallback})> askQuestion({
    required String question,
    List<ChatMessage> conversationHistory = const [],
  });

  Stream<String> streamQuestion({
    required String question,
    List<ChatMessage> conversationHistory = const [],
  });

  Future<void> saveApiKey(String key);
  Future<String?> getApiKey();
  Future<void> clearApiKey();
}
