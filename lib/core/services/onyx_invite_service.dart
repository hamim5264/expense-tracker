import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnyxInviteService {
  static const int requiredInvites = 5;
  static const String _keyInviteCount = 'onyx_invite_count';
  static const String _keyAiUnlocked = 'onyx_ai_unlocked';

  static final ValueNotifier<int> inviteCountNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<bool> isUnlockedNotifier = ValueNotifier<bool>(false);

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(_keyInviteCount) ?? 0;
      final unlocked = prefs.getBool(_keyAiUnlocked) ?? (count >= requiredInvites);

      inviteCountNotifier.value = count;
      isUnlockedNotifier.value = unlocked;
      _isInitialized = true;
    } catch (_) {}
  }

  static bool isAiUnlocked() {
    return isUnlockedNotifier.value;
  }

  static int getInviteCount() {
    return inviteCountNotifier.value;
  }

  static Future<int> recordInvite() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyInviteCount) ?? 0;
    if (current < requiredInvites) {
      current++;
      await prefs.setInt(_keyInviteCount, current);
    }

    final bool unlocked = current >= requiredInvites;
    if (unlocked) {
      await prefs.setBool(_keyAiUnlocked, true);
    }

    inviteCountNotifier.value = current;
    isUnlockedNotifier.value = unlocked;
    return current;
  }

  /// Helper to manually unlock or reset for testing if needed
  static Future<void> setUnlocked(bool unlocked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAiUnlocked, unlocked);
    isUnlockedNotifier.value = unlocked;
  }
}

