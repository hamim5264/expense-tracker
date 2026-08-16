import 'package:flutter/material.dart';

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showBackgroundBox;
  final bool isCircle;
  final bool showTrailingArrow;
  final Widget? trailing;

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.textColor,
    required this.onTap,
    this.isDestructive = false,
    this.showBackgroundBox = true,
    this.isCircle = false,
    this.showTrailingArrow = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color effectiveIconColor = isDestructive
        ? Colors.redAccent
        : (iconColor ?? (isDark ? Colors.white70 : Colors.black54));

    if (!isDestructive && isDark && effectiveIconColor.computeLuminance() < 0.25) {
      effectiveIconColor = Colors.purpleAccent.shade100;
    }

    final defaultTextColor = isDark ? Colors.white : Colors.black87;
    final actualTextColor = isDestructive
        ? Colors.redAccent
        : (textColor ?? defaultTextColor);

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: showBackgroundBox
                ? effectiveIconColor.withOpacity(isDark ? 0.22 : 0.12)
                : Colors.transparent,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: effectiveIconColor,
            size: showBackgroundBox ? 20 : 24,
          ),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.5,
            color: actualTextColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              )
            : null,
        trailing:
            trailing ??
            (showTrailingArrow
                ? (isDestructive
                      ? null
                      : const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        ))
                : null),
        onTap: onTap,
      ),
    );
  }
}
