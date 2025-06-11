import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _pinKey = 'pin_code';
  static const _bioKey = 'use_biometrics';
  static const _pinEnabledKey = 'use_pin';

  static Future<void> setPinCode(String pin) async =>
      _storage.write(key: _pinKey, value: pin);

  static Future<String?> getPinCode() async => _storage.read(key: _pinKey);

  static Future<void> deletePinCode() async => _storage.delete(key: _pinKey);

  static Future<bool> hasPinCode() async =>
      (await _storage.read(key: _pinKey)) != null;

  static Future<void> setUseBiometrics(bool value) async =>
      _storage.write(key: _bioKey, value: value.toString());

  static Future<bool> getUseBiometrics() async =>
      (await _storage.read(key: _bioKey)) == 'true';

  static Future<void> setUsePin(bool value) async =>
      _storage.write(key: _pinEnabledKey, value: value.toString());

  static Future<bool> getUsePin() async =>
      (await _storage.read(key: _pinEnabledKey)) != 'false';
}
