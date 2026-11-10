import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OtpSession {
  static const _keyTrustedUntil = 'otp_trusted_until';
  static final _storage = const FlutterSecureStorage();

  static Future<void> markTrustedFor30Days() async {
    final trustedUntil = DateTime.now().add(const Duration(days: 30));
    await _storage.write(key: _keyTrustedUntil, value: trustedUntil.toIso8601String());
  }

  static Future<bool> isTrusted() async {
    final s = await _storage.read(key: _keyTrustedUntil);
    if (s == null) return false;
    final dt = DateTime.tryParse(s);
    if (dt == null) return false;
    return DateTime.now().isBefore(dt);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _keyTrustedUntil);
  }
}
