import 'dart:convert';

import 'package:mini_duolingo/data/models/user_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProgressRepository {
  static const _storageKey = 'user_progress_v1';

  Future<UserProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) {
      return UserProgress.initial();
    }

    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProgress.fromJson(map);
    } catch (_) {
      return UserProgress.initial();
    }
  }

  Future<void> save(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(progress.toJson());
    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
