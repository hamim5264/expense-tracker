import 'dart:ui';
import 'package:flutter/material.dart';

class GlassColorSelector extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const GlassColorSelector({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
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

    final colorOptions = [
      {
        'color': const Color(0xFF4F378A),
        'title': 'Amethyst Purple',
        'subtitle': 'Classic royalty and elegance',
      },
      {
        'color': const Color(0xFF0083B0),
        'title': 'Ocean Blue',
        'subtitle': 'Calm, trust, and clarity',
      },
      {
        'color': const Color(0xFFFF5858),
        'title': 'Sunset Crimson',
        'subtitle': 'Bold, energetic, and warm',
      },
      {
        'color': const Color(0xFF232526),
        'title': 'Obsidian Dark',
        'subtitle': 'Minimalist, sleek, and tech',
      },
      {
        'color': const Color(0xFFD4AF37),
        'title': 'Golden Amber',
        'subtitle': 'Premium luxury and prestige',
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
                'Select Theme Color',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 16),
              ...colorOptions.map((opt) {
                final Color color = opt['color'] as Color;
                final isSelected = color.value == selectedColor.value;
                final title = opt['title'] as String;
                final subtitle = opt['subtitle'] as String;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withAlpha(30)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
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
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          color: titleColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onTap: () {
                        onColorSelected(color);
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
