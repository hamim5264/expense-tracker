import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class RateUsService {
  static const String _keyHasRated = 'has_user_rated_app';
  static const String _keyAppLaunchCount = 'app_launch_count';

  static Future<void> checkAndShowRateUsDialog(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasRated = prefs.getBool(_keyHasRated) ?? false;
      if (hasRated) return;

      int launches = prefs.getInt(_keyAppLaunchCount) ?? 0;
      launches++;
      await prefs.setInt(_keyAppLaunchCount, launches);

      if (launches >= 2) {
        if (!context.mounted) return;
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          barrierColor: Colors.black.withOpacity(0.6),
          builder: (ctx) => const RateUsBottomSheet(),
        );
      }
    } catch (_) {}
  }

  static Future<void> markUserHasRated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasRated, true);
    } catch (_) {}
  }
}

class RateUsBottomSheet extends StatefulWidget {
  const RateUsBottomSheet({super.key});

  @override
  State<RateUsBottomSheet> createState() => _RateUsBottomSheetState();
}

class _RateUsBottomSheetState extends State<RateUsBottomSheet> {
  int _selectedRating = 5;

  Future<void> _submitRating() async {
    await RateUsService.markUserHasRated();
    if (mounted) {
      Navigator.pop(context);
    }
    const playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.thedevhamim.onyx';
    final uri = Uri.parse(playStoreUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1B29) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.star_fill,
                color: Colors.amber.shade500,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enjoying Onyx?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your rating helps us improve Onyx and release new features!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = starIndex;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      starIndex <= _selectedRating
                          ? CupertinoIcons.star_fill
                          : CupertinoIcons.star,
                      color: Colors.amber.shade500,
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Maybe Later',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Rate on Play Store',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
