import 'package:flutter/material.dart';

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showBackgroundBox;
  final bool isCircle;
  final bool showTrailingArrow;

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.textColor,
    required this.onTap,
    this.isDestructive = false,
    this.showBackgroundBox = true,
    this.isCircle = false,
    this.showTrailingArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDestructive
        ? Colors.red
        : (iconColor ?? (isDark ? Colors.white70 : Colors.black54));
    final defaultTextColor = isDark ? Colors.white : Colors.black87;
    final actualTextColor = isDestructive
        ? Colors.red
        : (textColor ?? defaultTextColor);

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: showBackgroundBox
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: isCircle ? null : BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              )
            : Icon(icon, color: color, size: 28),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: actualTextColor,
          ),
        ),
        trailing: showTrailingArrow
            ? (isDestructive
                  ? null
                  : const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ))
            : null,
        onTap: onTap,
      ),
    );
  }
}
