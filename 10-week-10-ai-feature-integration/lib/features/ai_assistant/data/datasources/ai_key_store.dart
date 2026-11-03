import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiKeyStore {
  const AiKeyStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'ai_api_key';

  Future<void> saveApiKey(String key) async {
    await _storage.write(key: _key, value: key);
  }

  Future<String?> readApiKey() async {
    return _storage.read(key: _key);
  }

  Future<void> deleteApiKey() async {
    await _storage.delete(key: _key);
  }
}
