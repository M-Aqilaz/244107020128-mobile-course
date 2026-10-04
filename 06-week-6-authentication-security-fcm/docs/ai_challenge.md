# Laporan AI Challenge - Minggu 6
**Mata Kuliah:** Pemrograman Mobile  
**Topik:** Authentication & Security (FCM Push Notification)  
**Nama:** Muhammad Aqil Azami  
**NIM:** 244107020128  
**Kelas:** TI-3H  

---

## 1. Prompt yang Digunakan
Sesuai arahan pada Codelab Step 5, berikut prompt lengkap yang saya berikan kepada AI coding assistant untuk merancang arsitektur push service dan autentikasi:

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

---

## 2. Output Awal dari AI (Kode Mentah Sebelum Perbaikan)
Secara garis besar, AI menghasilkan boilerplate awal yang memiliki beberapa kelemahan arsitektur dan celah keamanan:

```dart
// Potongan kode awal yang digenerate AI:
class PushNotificationService {
  void init() {
    // KESALAHAN 1: Handler background didefinisikan sebagai closure di dalam kelas
    FirebaseMessaging.onBackgroundMessage((message) async {
      print("Handling a background message: ${message.messageId}");
    });

    // KESALAHAN 2: Hanya print di console, tidak memicu local notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
    });
  }
}

// KESALAHAN 3: Penyimpanan token disarankan menggunakan SharedPreferences
final prefs = await SharedPreferences.getInstance();
await prefs.setString('jwt_token', token);
```

---

## 3. Checklist Verifikasi Mahasiswa

| Kriteria Pemeriksaan | Status Awal AI | Status Akhir (Setelah Revisi) | Catatan Mahasiswa |
|---|:---:|:---:|---|
| **Background handler top-level & `@pragma('vm:entry-point')`** | ❌ Gagal | ✅ Memenuhi | Awalnya AI menaruh method di dalam closure class. Jika aplikasi di-*terminate* atau background isolate dijalankan, engine akan crash karena entry point hilang dari tree-shaking compiler. |
| **Masking Token FCM di UI** | ❌ Gagal | ✅ Memenuhi | AI menampilkan full raw token `fcm_token_xxxx` langsung di Text widget. Ini berisiko bocor saat demo atau screenshot/screen sharing. Saya buat fungsi `PushService.maskToken()`. |
| **Foreground message menampilkan notifikasi lokal** | ❌ Gagal | ✅ Memenuhi | AI awalnya hanya melakukan `print()` di console. Di mobile, notifikasi foreground tidak akan muncul di notification tray kecuali dipicu manual via `flutter_local_notifications`. |
| **Penanganan 3 App States (Foreground, Background, Terminated)** | ⚠️ Sebagian | ✅ Memenuhi | AI melupakan method `getInitialMessage()` untuk state terminated (cold start saat user klik notifikasi ketika app mati). Saya tambahkan di fungsi `handleTerminated()`. |
| **Penyimpanan Token Aman (OWASP Mobile Security)** | ❌ Gagal | ✅ Memenuhi | AI menyarankan `SharedPreferences` yang berupa file XML plaintext tidak terenkripsi di sandbox Android. Saya ubah menjadi `flutter_secure_storage` (Android Keystore & iOS Keychain). |

---

## 4. Perbaikan Manual yang Saya Lakukan

### a. Memindahkan Background Handler ke Top-Level Function
Saya memindahkan fungsi handler background ke luar class agar menjadi fungsi global (top-level) dan memberikan anotasi `@pragma('vm:entry-point')`:
```dart
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Isolate terpisah, tidak mengakses BuildContext atau UI state
}
```

### b. Implementasi Masking Token
Agar tidak melanggar pedoman keamanan data sensitif OWASP Mobile Security, saya menambahkan fungsi pemotongan string token:
```dart
static String maskToken(String? token) {
  if (token == null || token.isEmpty) return 'Belum tersedia';
  if (token.length <= 16) return token;
  final start = token.substring(0, 8);
  final end = token.substring(token.length - 6);
  return '$start...$end';
}
```

### c. Integrasi Flutter Local Notifications untuk Foreground
Ketika aplikasi aktif (foreground), sistem operasi Android/iOS tidak memunculkan banner notifikasi otomatis dari FCM. Saya menghubungkan event `FirebaseMessaging.onMessage` dengan instance `FlutterLocalNotificationsPlugin` sehingga notifikasi heads-up tetap muncul dengan channel berprioritas tinggi (`importance: Importance.high`).

### d. Cold Start / Terminated State Handling
Saya melengkapi navigasi deep link saat aplikasi dibuka dari keadaan mati (terminated) dengan memanfaatkan `getInitialMessage()`:
```dart
final initial = await FirebaseMessaging.instance.getInitialMessage();
if (initial != null) {
  final route = routeFromMessage(initial.data);
  router.go(route);
}
```
Hasil parsing payload `data: {'type': 'announcement', 'id': '1'}` langsung mengarahkan user ke `/pengumuman/1`.

---

## 5. Kesimpulan Refleksi
Bantuan AI sangat mempercepat pembuatan boilerplate, namun kode yang dihasilkan rentan memiliki celah keamanan serius (seperti menyimpan JWT di SharedPreferences) dan kesalahan arsitektur mobile lifecycle (background handler di dalam class, ketiadaan notifikasi lokal saat foreground). Validasi manual dan pemahaman konsep dasar tetap wajib dilakukan oleh mahasiswa.
