import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes.dart';
import '../providers/ai_chat_providers.dart';
import '../widgets/api_key_dialog.dart';
import '../widgets/chat_bubble.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  late final TextEditingController _textController;
  late final ScrollController _scrollController;

  final List<String> _quickPrompts = [
    'Jadwal UTS ganjil?',
    'Info server down?',
    'Ruang kelas TI-3H?',
    'Tips belajar Flutter?',
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScenarioParameters();
    });
  }

  void _checkScenarioParameters() {
    final uri = Uri.base.toString();
    String routerUri = '';
    try {
      routerUri = GoRouterState.of(context).uri.toString();
    } catch (_) {}
    final full = '$uri $routerUri';

    if (full.contains('scenario=ai_chat_demo')) {
      ref.read(aiChatMessagesProvider.notifier).sendMessage('Jadwal UTS ganjil?');
    } else if (full.contains('scenario=ai_key_dialog')) {
      showDialog(
        context: context,
        builder: (_) => const ApiKeyDialog(),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    ref.read(aiChatMessagesProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messages = ref.watch(aiChatMessagesProvider);
    final isStreaming = ref.watch(aiStreamingStatusProvider);
    final apiKey = ref.watch(aiApiKeyProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tanya Asisten AI',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: apiKey != null && apiKey.isNotEmpty
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  apiKey != null && apiKey.isNotEmpty
                      ? 'Cloud Gemini AI'
                      : 'Mode Pengetahuan Kampus (Offline)',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Pengaturan API Key',
            icon: const Icon(Icons.key_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const ApiKeyDialog(),
              );
            },
          ),
          IconButton(
            tooltip: 'Bersihkan Obrolan',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              ref.read(aiChatMessagesProvider.notifier).clearChat();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Privasi & OWASP Data Protection (Step 4 Codelab)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: Colors.blue.shade800,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Privasi Terjaga: NIK, No. HP, dan token otomatis disensor sebelum dikirim.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daftar Pesan Percakapan
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatBubble(
                  key: Key('bubble_${message.id}'),
                  message: message,
                  onRetry: () {
                    // Retry pesan
                    if (index > 0) {
                      final prevUserMsg = messages[index - 1];
                      ref
                          .read(aiChatMessagesProvider.notifier)
                          .sendMessage(prevUserMsg.text);
                    }
                  },
                );
              },
            ),
          ),

          // Preset Pertanyaan Cepat (Quick Prompt Chips)
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final prompt = _quickPrompts[i];
                return ActionChip(
                  key: Key('chip_prompt_$i'),
                  label: Text(
                    prompt,
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
                  ),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  onPressed: isStreaming
                      ? null
                      : () {
                          ref
                              .read(aiChatMessagesProvider.notifier)
                              .sendMessage(prompt);
                          _scrollToBottom();
                        },
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          // Input Bar Box dengan dukungan OCR & Voice mock
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // OCR Feature Mock Icon (Step 3)
                  IconButton(
                    tooltip: 'OCR: Pindai Dokumen / KTM',
                    icon: Icon(Icons.document_scanner_outlined, color: Colors.grey.shade700),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur OCR: Ekstraksi teks dari foto dokumen aktif.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  // Speech-to-Text Mock Icon (Step 3)
                  IconButton(
                    tooltip: 'Speech-to-Text: Rekam Suara',
                    icon: Icon(Icons.mic_none_rounded, color: Colors.grey.shade700),
                    onPressed: () {
                      _textController.text = 'Jadwal ujian tengah semester?';
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Speech-to-Text: Suara terkonversi menjadi teks.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      key: const Key('ai_chat_input'),
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      decoration: InputDecoration(
                        hintText: 'Tanyakan sesuatu ke Asisten AI...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: isStreaming
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : IconButton(
                            key: const Key('btn_send_ai'),
                            icon: const Icon(
                              Icons.send_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: _handleSend,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
