import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnyxAiCreditsService {
  static const String _keyCredits = 'onyx_ai_chat_credits';
  static const int creditsPerRewardedAd = 3;

  static final ValueNotifier<int> creditsNotifier = ValueNotifier<int>(0);
  static bool _isInitialized = false;

  /// Initialize and load saved credits from SharedPreferences
  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(_keyCredits) ?? 0;
      creditsNotifier.value = count;
      _isInitialized = true;
    } catch (e) {
      debugPrint('[OnyxAiCreditsService] Init error: $e');
    }
  }

  /// Current available chat credits
  static int get credits => creditsNotifier.value;

  /// Check if user has at least 1 credit to chat
  static bool get hasCredits => creditsNotifier.value > 0;

  /// Add credits (default +3 for watching a rewarded video ad)
  static Future<int> addCredits([int count = creditsPerRewardedAd]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyCredits) ?? 0;
      final updated = current + count;
      await prefs.setInt(_keyCredits, updated);
      creditsNotifier.value = updated;
      return updated;
    } catch (e) {
      debugPrint('[OnyxAiCreditsService] addCredits error: $e');
      creditsNotifier.value += count;
      return creditsNotifier.value;
    }
  }

  /// Deduct 1 credit for sending an AI message. Returns true if successful.
  static Future<bool> consumeCredit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyCredits) ?? 0;
      if (current <= 0) return false;
      final updated = current - 1;
      await prefs.setInt(_keyCredits, updated);
      creditsNotifier.value = updated;
      return true;
    } catch (e) {
      debugPrint('[OnyxAiCreditsService] consumeCredit error: $e');
      if (creditsNotifier.value > 0) {
        creditsNotifier.value -= 1;
        return true;
      }
      return false;
    }
  }

  /// Helper to set credits manually
  static Future<void> setCredits(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCredits, count);
    creditsNotifier.value = count;
  }
}
