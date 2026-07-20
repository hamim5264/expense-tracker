import 'dart:ui';
import 'package:flutter/material.dart';

class GlassThemeSelector extends StatelessWidget {
  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onThemeSelected;

  const GlassThemeSelector({
    super.key,
    required this.selectedMode,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final glassBg = isDark
        ? Colors.black.withAlpha(160)
        : Colors.white.withAlpha(200);
    final borderColor = isDark
        ? Colors.white.withAlpha(30)
        : Colors.black.withAlpha(20);
    final titleColor = isDark ? Colors.white : Colors.black87;

    final options = [
      {
        'mode': ThemeMode.system,
        'title': 'System Default',
        'subtitle': 'Follow phone settings',
        'icon': Icons.brightness_auto_rounded,
      },
      {
        'mode': ThemeMode.light,
        'title': 'Light Mode',
        'subtitle': 'Bright and clear display',
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'mode': ThemeMode.dark,
        'title': 'Dark Mode',
        'subtitle': 'Sleek and battery friendly',
        'icon': Icons.dark_mode_outlined,
      },
    ];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: glassBg,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white30 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Theme Mode',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((opt) {
                final mode = opt['mode'] as ThemeMode;
                final isSelected = mode == selectedMode;
                final title = opt['title'] as String;
                final subtitle = opt['subtitle'] as String;
                final icon = opt['icon'] as IconData;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primaryColor.withAlpha(30)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      leading: Icon(
                        icon,
                        color: isSelected
                            ? theme.primaryColor
                            : (isDark ? Colors.white70 : Colors.black54),
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? theme.primaryColor
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? theme.primaryColor.withAlpha(200)
                              : (isDark ? Colors.white54 : Colors.black54),
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: theme.primaryColor,
                            )
                          : null,
                      onTap: () {
                        onThemeSelected(mode);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
