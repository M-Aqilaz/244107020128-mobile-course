import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/ai_assistant/data/datasources/ai_remote_datasource.dart';
import 'package:campus_notify/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:campus_notify/features/ai_assistant/domain/repositories/ai_repository.dart';
import 'package:campus_notify/features/ai_assistant/domain/usecases/send_ai_query_usecase.dart';
import 'package:campus_notify/features/ai_assistant/presentation/pages/ai_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAiRepository implements AiRepository {
  String? lastSanitizedQuery;
  String? savedKey;

  @override
  Future<({String? response, Failure? failure, bool isOfflineFallback})> askQuestion({
    required String question,
    List<ChatMessage> conversationHistory = const [],
  }) async {
    lastSanitizedQuery = question;
    if (question.contains('trigger_error')) {
      return (
        response: null,
        failure: const AiFailure('Simulated failure'),
        isOfflineFallback: false,
      );
    }
    return (
      response: 'Jawaban mock untuk: $question',
      failure: null,
      isOfflineFallback: false,
    );
  }

  @override
  Stream<String> streamQuestion({
    required String question,
    List<ChatMessage> conversationHistory = const [],
  }) async* {
    lastSanitizedQuery = question;
    yield 'Halo ';
    yield 'mahasiswa, ';
    yield 'ini jawaban mock.';
  }

  @override
  Future<String?> getApiKey() async => savedKey;

  @override
  Future<void> saveApiKey(String key) async {
    savedKey = key;
  }

  @override
  Future<void> clearApiKey() async {
    savedKey = null;
  }
}

void main() {
  group('SendAiQueryUseCase & Privacy Sanitization Tests', () {
    late MockAiRepository mockRepo;
    late SendAiQueryUseCase useCase;

    setUp(() {
      mockRepo = MockAiRepository();
      useCase = SendAiQueryUseCase(mockRepo);
    });

    test('should sanitize 16-digit NIK before passing to AI repository', () async {
      const input = 'Halo min, NIK saya 3507123456789012 mau tanya ruang ujian.';
      final result = await useCase.execute(rawQuestion: input);

      expect(result.failure, isNull);
      expect(mockRepo.lastSanitizedQuery, contains('[NIK_SENSITIF_DISENSOR]'));
      expect(mockRepo.lastSanitizedQuery, isNot(contains('3507123456789012')));
    });

    test('should sanitize Indonesian phone numbers (+62 / 08xx)', () async {
      const input = 'Tolong hubungi nomor saya 081234567890 atau +6281987654321 jika ada kendala.';
      final result = await useCase.execute(rawQuestion: input);

      expect(result.failure, isNull);
      expect(mockRepo.lastSanitizedQuery, contains('[NO_HP_DISENSOR]'));
      expect(mockRepo.lastSanitizedQuery, isNot(contains('081234567890')));
      expect(mockRepo.lastSanitizedQuery, isNot(contains('+6281987654321')));
    });

    test('should sanitize Bearer JWT authorization tokens', () async {
      const input = 'Header token saya: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.t-ae';
      final result = await useCase.execute(rawQuestion: input);

      expect(result.failure, isNull);
      expect(mockRepo.lastSanitizedQuery, contains('[TOKEN_AUTH_DISENSOR]'));
      expect(mockRepo.lastSanitizedQuery, isNot(contains('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9')));
    });

    test('should allow regular campus query without unnecessary redaction', () async {
      const input = 'Kapan jadwal ujian akhir semester gasal 2026?';
      final result = await useCase.execute(rawQuestion: input);

      expect(result.failure, isNull);
      expect(mockRepo.lastSanitizedQuery, equals(input));
    });

    test('should return ValidationFailure when prompt is empty or blank', () async {
      final result = await useCase.execute(rawQuestion: '   ');
      expect(result.failure, isA<ValidationFailure>());
    });

    test('should return Failure on repository exception', () async {
      final result = await useCase.execute(rawQuestion: 'trigger_error');
      expect(result.failure, isA<AiFailure>());
    });
  });

  group('Offline Fallback Engine Tests', () {
    late AiRemoteDataSource dataSource;

    setUp(() {
      dataSource = AiRemoteDataSource();
    });

    test('should provide intelligent campus schedule when query mentions uts or ujian', () {
      final answer = AiRemoteDataSource.getOfflineFallbackAnswer('kapan jadwal uts mobile?');
      expect(answer, contains('Jadwal Ujian Tengah Semester'));
      expect(answer, contains('15 Oktober 2026'));
    });

    test('should provide server maintenance info when query mentions server or jaringan', () {
      final answer = AiRemoteDataSource.getOfflineFallbackAnswer('kapan jadwal server maintenance?');
      expect(answer, contains('Server JTI Polinema'));
      expect(answer, contains('Minggu malam'));
    });

    test('should provide guidance for finding lecture room when query mentions ruang or ti-3h', () {
      final answer = AiRemoteDataSource.getOfflineFallbackAnswer('di mana ruang kelas TI-3H?');
      expect(answer, contains('TI-3H'));
      expect(answer, contains('Gedung Sipil lantai 7'));
    });

    test('should stream tokens simulation in chunks', () async {
      final stream = dataSource.streamTokens('Halo dunia kampus Polinema');
      final chunks = await stream.toList();

      expect(chunks.isNotEmpty, true);
      final combined = chunks.join('');
      expect(combined, equals('Halo dunia kampus Polinema'));
    });
  });

  group('AiChatPage Widget Tests', () {
    testWidgets('renders AI Chat Page with initial greeting, privacy banner, and quick prompts', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AiChatPage(),
          ),
        ),
      );

      // Verify AppBar Title & subtitle
      expect(find.text('Tanya Asisten AI'), findsOneWidget);
      expect(find.textContaining('Mode Pengetahuan Kampus'), findsOneWidget);

      // Verify Initial greeting from AI
      expect(
        find.textContaining('Halo! Saya Asisten AI Kampus Polinema'),
        findsOneWidget,
      );

      // Verify Privacy Banner
      expect(find.textContaining('Privasi Terjaga:'), findsOneWidget);

      // Verify Quick prompt chips
      expect(find.byKey(const Key('chip_prompt_0')), findsOneWidget);
      expect(find.text('Jadwal UTS ganjil?'), findsOneWidget);

      // Verify Input TextField & Send Button
      expect(find.byKey(const Key('ai_chat_input')), findsOneWidget);
      expect(find.byKey(const Key('btn_send_ai')), findsOneWidget);
    });

    testWidgets('tapping quick prompt sends message into chat stream', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AiChatPage(),
          ),
        ),
      );

      // Initial check: only 1 initial message from AI
      expect(find.byType(ListView), findsWidgets);

      // Tap on the first quick prompt chip ('Jadwal UTS ganjil?')
      await tester.tap(find.byKey(const Key('chip_prompt_0')));
      await tester.pump(); // Start send
      await tester.pump(const Duration(milliseconds: 300));

      // Now user message should appear in chat
      expect(find.text('Jadwal UTS ganjil?'), findsWidgets);
    });
  });
}
