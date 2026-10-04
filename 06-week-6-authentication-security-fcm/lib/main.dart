import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'providers/push_provider.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'rootNav');

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      if (authAsync.isLoading) return null;

      final isAuth = authAsync.asData?.value ?? false;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      // Skenario khusus via URL query parameter (pengujian/screenshot)
      final uri = state.uri.toString();
      if (uri.contains('auth=false')) {
        return isLoggingIn ? null : AppRoutes.login;
      }
      if (uri.contains('auth=true') || uri.contains('scenario=')) {
        if (isLoggingIn) return AppRoutes.home;
        return null;
      }

      if (!isAuth) {
        return isLoggingIn ? null : AppRoutes.login;
      }

      if (isLoggingIn) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.announcementPattern,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '1';
          return AnnouncementPage(id: id);
        },
      ),
    ],
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase & FCM aman (tidak crash jika tanpa google-services)
  final pushService = PushService();
  await pushService.initFirebaseSafe();

  runApp(
    ProviderScope(
      overrides: [
        pushServiceProvider.overrideWithValue(pushService),
      ],
      child: const CampusNotifyApp(),
    ),
  );
}

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key});

  @override
  ConsumerState<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends ConsumerState<CampusNotifyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPushNotifications();
    });
  }

  Future<void> _initPushNotifications() async {
    final push = ref.read(pushServiceProvider);
    final router = ref.read(routerProvider);

    await push.requestNotificationPermission();

    await push.initLocalNotifications(
      onSelectNotification: (route) {
        router.go(route);
      },
    );

    await push.initFcmToken(
      onToken: (token) async {
        ref.read(fcmTokenProvider.notifier).updateToken(token);
      },
    );

    push.listenForeground((route) {
      router.go(route);
    });

    await push.handleTerminated((route) {
      router.go(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Campus Notify - Polinema',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Biru Navy Polinema
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      routerConfig: router,
    );
  }
}
