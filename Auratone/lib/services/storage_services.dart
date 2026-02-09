import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile.dart';

class StorageService {
  final _storage = FlutterSecureStorage();

  Future<void> saveUserProfile(UserProfile profile) async {
    await _storage.write(
        key: 'user_profile', value: jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> loadUserProfile() async {
    final data = await _storage.read(key: 'user_profile');
    if (data == null) return null;
    return UserProfile.fromJson(jsonDecode(data));
  }
}
