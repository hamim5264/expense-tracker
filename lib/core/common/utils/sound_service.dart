import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _soundEnabled = true;
  static bool _vibrateEnabled = true;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrateEnabled = prefs.getBool('vibrate_enabled') ?? true;
    } catch (e) {
      debugPrint('Error initializing SoundService: $e');
    }
  }

  static bool get soundEnabled => _soundEnabled;

  static bool get vibrateEnabled => _vibrateEnabled;

  static Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);
  }

  static Future<void> setVibrateEnabled(bool enabled) async {
    _vibrateEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrate_enabled', enabled);
  }

  static Future<void> playSuccess() async {
    if (_soundEnabled) {
      try {
        await _player.stop();
        await _player.play(AssetSource('sound_effects/success_sound.mp3'));
      } catch (e) {
        debugPrint('Error playing success sound: $e');
      }
    }
    if (_vibrateEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  static Future<void> playFailed() async {
    if (_soundEnabled) {
      try {
        await _player.stop();
        await _player.play(AssetSource('sound_effects/failed_sound.mp3'));
      } catch (e) {
        debugPrint('Error playing failed sound: $e');
      }
    }
    if (_vibrateEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
}
