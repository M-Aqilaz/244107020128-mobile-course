import '../../../../core/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_key_store.dart';
import '../datasources/ai_remote_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl({
    AiRemoteDataSource? remoteDataSource,
    AiKeyStore? keyStore,
  })  : _remoteDataSource = remoteDataSource ?? AiRemoteDataSource(),
        _keyStore = keyStore ?? const AiKeyStore();

  final AiRemoteDataSource _remoteDataSource;
  final AiKeyStore _keyStore;

  @override
  Future<({String? response, Failure? failure, bool isOfflineFallback})> askQuestion({
    required String question,
    List<ChatMessage> conversationHistory = const [],
  }) async {
    try {
      final apiKey = await _keyStore.readApiKey();
      final result = await _remoteDataSource.generateAnswer(
        question: question,
        apiKey: apiKey,
      );
      return (
        response: result.text,
        failure: null,
        isOfflineFallback: result.isOfflineFallback,
      );
    } catch (e) {
      return (
        response: null,
        failure: AiFailure('Gagal memproses pesan AI: $e'),
        isOfflineFallback: false,
      );
    }
  }

  @override
  Stream<String> streamQuestion({
    required String question,
    List<ChatMessage> conversationHistory = const [],
  }) async* {
    final apiKey = await _keyStore.readApiKey();
    final result = await _remoteDataSource.generateAnswer(
      question: question,
      apiKey: apiKey,
    );

    yield* _remoteDataSource.streamTokens(result.text);
  }

  @override
  Future<void> saveApiKey(String key) async {
    await _keyStore.saveApiKey(key);
  }

  @override
  Future<String?> getApiKey() async {
    return _keyStore.readApiKey();
  }

  @override
  Future<void> clearApiKey() async {
    await _keyStore.deleteApiKey();
  }
}
