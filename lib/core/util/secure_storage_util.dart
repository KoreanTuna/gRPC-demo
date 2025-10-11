import 'package:grpc_study/core/constant/secure_storage_key.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@module
abstract class SecureStorageModule {
  @singleton
  FlutterSecureStorage createSecureStorage() => const FlutterSecureStorage();
}

@singleton
class SecureStorageUtil {
  SecureStorageUtil(this._flutterSecureStorage);
  final FlutterSecureStorage _flutterSecureStorage;

  Future<String?> getAccessToken() async {
    return _read(SecureStorageKey.accessToken);
  }

  Future<String?> getRefreshToken() async {
    return _read(SecureStorageKey.refreshToken);
  }

  Future<void> saveAccessToken(String token) async {
    await _write(key: SecureStorageKey.accessToken, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _write(key: SecureStorageKey.refreshToken, value: token);
  }

  Future<void> deleteAccessToken() async {
    await _delete(SecureStorageKey.accessToken);
  }

  Future<void> deleteRefreshToken() async {
    await _delete(SecureStorageKey.refreshToken);
  }

  Future<void> deleteAll() async {
    await _flutterSecureStorage.deleteAll();
  }

  Future<void> _write({required String key, required String value}) async {
    await _flutterSecureStorage.write(key: key, value: value);
  }

  Future<String?> _read(String key) async {
    return _flutterSecureStorage.read(key: key);
  }

  Future<bool> _containsKey(String key) async {
    return _flutterSecureStorage.containsKey(key: key);
  }

  Future<void> _delete(String key) async {
    await _flutterSecureStorage.delete(key: key);
  }
}
