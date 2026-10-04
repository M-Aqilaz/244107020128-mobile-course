import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'route_parser.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler top-level wajib @pragma('vm:entry-point').
  // Berjalan di isolate terpisah, dilarang mengakses BuildContext atau state UI.
}

class PushService {
  PushService({
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _local = localNotifications ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _local;
  String? pendingDeepLink;
  String? _currentToken;
  bool _isFirebaseReady = false;

  final _foregroundMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get foregroundMessages =>
      _foregroundMessageController.stream;

  bool get isFirebaseReady => _isFirebaseReady;
  String? get currentToken => _currentToken;

  static String maskToken(String? token) {
    if (token == null || token.isEmpty) return 'Belum tersedia';
    if (token.length <= 16) return token;
    final start = token.substring(0, 8);
    final end = token.substring(token.length - 6);
    return '$start...$end';
  }

  Future<void> initFirebaseSafe() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _isFirebaseReady = true;
    } catch (_) {
      _isFirebaseReady = false;
    }
  }

  Future<bool> requestNotificationPermission() async {
    if (!_isFirebaseReady) return true;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  Future<void> initLocalNotifications({
    void Function(String route)? onSelectNotification,
  }) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    const linux = LinuxInitializationSettings(defaultActionName: 'Open');

    await _local.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
        linux: linux,
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          pendingDeepLink = payload;
          if (onSelectNotification != null) {
            onSelectNotification(payload);
          }
        }
      },
    );
  }

  Future<void> initFcmToken({
    required Future<void> Function(String token) onToken,
  }) async {
    if (_isFirebaseReady) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          _currentToken = token;
          await onToken(token);
        }
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
          _currentToken = newToken;
          await onToken(newToken);
        });
        await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
        return;
      } catch (_) {}
    }

    // Fallback token terenkripsi simulasi jika dijalankan di emulator/web tanpa google-services
    _currentToken =
        'fcm_token_campus_244107020128_${DateTime.now().millisecondsSinceEpoch}';
    await onToken(_currentToken!);
  }

  void listenForeground(void Function(String route) go) {
    if (_isFirebaseReady) {
      FirebaseMessaging.onMessage.listen((message) async {
        final route = routeFromMessage(message.data);
        final title = message.notification?.title ?? 'Pengumuman Baru';
        final body = message.notification?.body ?? 'Ada pengumuman dari kampus.';

        _foregroundMessageController.add({
          'title': title,
          'body': body,
          'route': route,
        });

        await showLocalNotification(
          title: title,
          body: body,
          payload: route,
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final route = routeFromMessage(message.data);
        go(route);
      });
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pengumuman_kampus',
      'Pengumuman Kampus',
      channelDescription: 'Saluran notifikasi pengumuman perkuliahan Polinema',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  Future<void> handleTerminated(void Function(String route) go) async {
    if (_isFirebaseReady) {
      try {
        final initial = await FirebaseMessaging.instance.getInitialMessage();
        if (initial != null) {
          final route = routeFromMessage(initial.data);
          go(route);
          return;
        }
      } catch (_) {}
    }

    if (pendingDeepLink != null) {
      final route = pendingDeepLink!;
      pendingDeepLink = null;
      go(route);
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    if (_isFirebaseReady) {
      try {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
      } catch (_) {}
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (_isFirebaseReady) {
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      } catch (_) {}
    }
  }

  /// Simulasi notifikasi masuk untuk demonstrasi langsung dan pengujian
  Future<void> simulateIncomingPush({
    required String title,
    required String body,
    required String route,
    void Function(String route)? onNavigate,
  }) async {
    _foregroundMessageController.add({
      'title': title,
      'body': body,
      'route': route,
    });

    await showLocalNotification(
      title: title,
      body: body,
      payload: route,
    );
  }

  void dispose() {
    _foregroundMessageController.close();
  }
}
