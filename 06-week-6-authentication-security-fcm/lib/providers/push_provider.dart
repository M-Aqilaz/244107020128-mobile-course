import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../messaging/push_service.dart';

final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService();
  ref.onDispose(service.dispose);
  return service;
});

class FcmTokenNotifier extends Notifier<String?> {
  @override
  String? build() => 'fcm_token_polinema_244107020128_9b2d';

  void updateToken(String token) {
    state = token;
  }
}

final fcmTokenProvider =
    NotifierProvider<FcmTokenNotifier, String?>(FcmTokenNotifier.new);

class TopicSubscribedNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setSubscribed(bool value) {
    state = value;
  }
}

final topicSubscribedProvider =
    NotifierProvider<TopicSubscribedNotifier, bool>(TopicSubscribedNotifier.new);
