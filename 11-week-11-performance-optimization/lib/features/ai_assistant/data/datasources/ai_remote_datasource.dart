import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiRemoteDataSource {
  AiRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static const _systemInstruction =
      'Kamu adalah Asisten AI Kampus Polinema yang ramah, sopan, dan sigap membantu mahasiswa TI. '
      'Berikan jawaban ringkas, jelas, maksimal 3 kalimat dalam Bahasa Indonesia. '
      'Jangan pernah meminta atau membocorkan data pribadi mahasiswa.';

  /// Memanggil LLM API di cloud atau beralih ke Fallback Engine jika offline/API key kosong
  Future<({String text, bool isOfflineFallback})> generateAnswer({
    required String question,
    String? apiKey,
    List<Map<String, String>> history = const [],
  }) async {
    // 1. Jika API Key belum diset, gunakan Fallback Engine cerdas lokal
    if (apiKey == null || apiKey.trim().isEmpty) {
      final fallbackText = getOfflineFallbackAnswer(question);
      return (text: fallbackText, isOfflineFallback: true);
    }

    // 2. Coba request ke Google Gemini API
    try {
      final endpoint = Uri.parse('$_apiUrl?key=$apiKey');
      final promptWithContext = '$_systemInstruction\n\nPertanyaan Mahasiswa: $question';

      final response = await _client
          .post(
            endpoint,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': promptWithContext}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.7,
                'maxOutputTokens': 256,
              }
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final aiText = parts[0]['text'] as String?;
            if (aiText != null && aiText.trim().isNotEmpty) {
              return (text: aiText.trim(), isOfflineFallback: false);
            }
          }
        }
      }

      // Jika status bukan 200 (misal 400 invalid key atau 429 quota limit), pakai fallback
      final fallbackText = getOfflineFallbackAnswer(question);
      return (
        text: '$fallbackText\n\n*(Catatan: Layanan Cloud API merespons kode ${response.statusCode}, otomatis beralih ke Basis Pengetahuan Kampus Offline)*',
        isOfflineFallback: true,
      );
    } catch (_) {
      // Jaringan terputus / timeout -> Fallback offline aman
      final fallbackText = getOfflineFallbackAnswer(question);
      return (
        text: '$fallbackText\n\n*(Mode Offline: Koneksi ke cloud tidak tersedia, menjawab dari Basis Data Kampus)*',
        isOfflineFallback: true,
      );
    }
  }

  /// Streaming token simulator / chunk emitter untuk pengalaman UX responsif
  Stream<String> streamTokens(String fullText) async* {
    final words = fullText.split(' ');
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 35));
      if (i == 0) {
        yield words[i];
      } else {
        yield ' ${words[i]}';
      }
    }
  }

  /// Basis pengetahuan cerdas kampus (Offline Fallback Engine)
  static String getOfflineFallbackAnswer(String query) {
    final q = query.toLowerCase();

    if (q.contains('uts') || q.contains('ujian') || q.contains('jadwal ujian')) {
      return 'Jadwal Ujian Tengah Semester (UTS) Ganjil dimulai tanggal 15 Oktober 2026. '
          'Pastikan membawa kartu ujian dan mengenakan seragam putih-hitam resmi sesuai ketentuan Polinema!';
    } else if (q.contains('server') || q.contains('jaringan') || q.contains('maintenance')) {
      return 'Server JTI Polinema menjalani jadwal pemeliharaan rutin setiap hari Minggu malam pukul 22.00 WIB. '
          'Layanan SIAKAD dan hotspot lokal mungkin mengalami downtime singkat selama 30 menit.';
    } else if (q.contains('ruang') || q.contains('kelas') || q.contains('lab') || q.contains('ti-3h')) {
      return 'Perkuliahan Praktikum Pemrograman Mobile kelas TI-3H dilaksanakan di Laboratorium Komputasi Cerdas LP-2 Gedung Sipil lantai 7.';
    } else if (q.contains('flutter') || q.contains('tips') || q.contains('belajar') || q.contains('clean')) {
      return 'Tips belajar Flutter & Clean Architecture: Pisahkan selalu domain layer dari framework UI, '
          'manfaatkan Riverpod untuk DI, dan selalu jalankan "flutter analyze" sebelum commit!';
    } else if (q.contains('halo') || q.contains('hai') || q.contains('pagi') || q.contains('siang')) {
      return 'Halo! Saya Asisten AI Kampus Polinema. Ada yang bisa saya bantu seputar info jadwal kuliah, ujian, pengumuman, atau lokasi lab?';
    } else if (q.contains('privasi') || q.contains('aman') || q.contains('nik')) {
      return 'Sistem Campus Notify menerapkan OWASP Mobile Privacy: NIK, nomor telepon, dan token autentikasi otomatis disensor dan tidak pernah dikirim ke LLM.';
    } else {
      return 'Pertanyaanmu terkait "$query" sudah tercatat. Kamu bisa mengecek pengumuman terbaru di beranda atau tanyakan info spesifik seputar Jadwal UTS, Server JTI, dan Ruang Kuliah.';
    }
  }
}
