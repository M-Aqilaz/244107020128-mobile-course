import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/ai_key_store.dart';
import '../../data/datasources/ai_remote_datasource.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/usecases/send_ai_query_usecase.dart';

// Data Sources & Repository Providers
final aiKeyStoreProvider = Provider<AiKeyStore>((ref) {
  return const AiKeyStore();
});

final aiRemoteDataSourceProvider = Provider<AiRemoteDataSource>((ref) {
  return AiRemoteDataSource();
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl(
    remoteDataSource: ref.watch(aiRemoteDataSourceProvider),
    keyStore: ref.watch(aiKeyStoreProvider),
  );
});

// Domain Use Case Provider
final sendAiQueryUseCaseProvider = Provider<SendAiQueryUseCase>((ref) {
  return SendAiQueryUseCase(ref.watch(aiRepositoryProvider));
});

// Status API Key Terpasang / Belum
class AiApiKeyNotifier extends Notifier<String?> {
  @override
  String? build() {
    // Membaca status awal
    ref.read(aiRepositoryProvider).getApiKey().then((val) {
      state = val;
    });
    return null;
  }

  Future<void> setKey(String key) async {
    await ref.read(aiRepositoryProvider).saveApiKey(key);
    state = key;
  }

  Future<void> removeKey() async {
    await ref.read(aiRepositoryProvider).clearApiKey();
    state = null;
  }
}

final aiApiKeyProvider = NotifierProvider<AiApiKeyNotifier, String?>(
  AiApiKeyNotifier.new,
);

// Indikator AI Sedang Mengetik / Streaming
class AiStreamingStatusNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setStreaming(bool status) {
    state = status;
  }
}

final aiStreamingStatusProvider =
    NotifierProvider<AiStreamingStatusNotifier, bool>(
  AiStreamingStatusNotifier.new,
);

// State Chat Messages Notifier
class AiChatMessagesNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() {
    return [
      ChatMessage(
        id: 'msg_welcome',
        text: 'Halo! Saya Asisten AI Kampus Polinema. Ada yang bisa saya bantu terkait jadwal kuliah, ujian UTS, lokasi ruang, atau pengumuman kampus?',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        isOfflineFallback: true,
      ),
    ];
  }

  Future<void> sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    final userMsgId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final aiMsgId = 'ai_${DateTime.now().millisecondsSinceEpoch}';

    final userMessage = ChatMessage(
      id: userMsgId,
      text: cleanText,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    final initialAiMessage = ChatMessage(
      id: aiMsgId,
      text: '',
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    // Tambahkan pesan user dan placeholder balasan AI
    state = [...state, userMessage, initialAiMessage];
    ref.read(aiStreamingStatusProvider.notifier).setStreaming(true);

    try {
      final useCase = ref.read(sendAiQueryUseCaseProvider);
      final stream = useCase.executeStream(
        rawQuestion: cleanText,
        history: state,
      );

      var accumulatedText = '';
      await for (final chunk in stream) {
        accumulatedText += chunk;
        state = [
          for (final msg in state)
            if (msg.id == aiMsgId)
              msg.copyWith(
                text: accumulatedText,
                isStreaming: true,
              )
            else
              msg,
        ];
      }

      // Selesai streaming
      state = [
        for (final msg in state)
          if (msg.id == aiMsgId)
            msg.copyWith(
              text: accumulatedText.isNotEmpty
                  ? accumulatedText
                  : 'Maaf, saya tidak dapat memproses jawaban saat ini.',
              isStreaming: false,
              isOfflineFallback: accumulatedText.contains('Mode Offline') ||
                  accumulatedText.contains('Offline'),
            )
          else
            msg,
      ];
    } catch (e) {
      state = [
        for (final msg in state)
          if (msg.id == aiMsgId)
            msg.copyWith(
              text: 'Terjadi kendala saat menghubungi asisten AI: $e. Silakan coba lagi.',
              isStreaming: false,
              isError: true,
            )
          else
            msg,
      ];
    } finally {
      ref.read(aiStreamingStatusProvider.notifier).setStreaming(false);
    }
  }

  void clearChat() {
    state = [
      ChatMessage(
        id: 'msg_welcome_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Percakapan telah direset. Silakan tanyakan hal baru yang ingin kamu ketahui seputar kampus!',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        isOfflineFallback: true,
      ),
    ];
  }
}

final aiChatMessagesProvider =
    NotifierProvider<AiChatMessagesNotifier, List<ChatMessage>>(
  AiChatMessagesNotifier.new,
);
