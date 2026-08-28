import 'package:flutter/material.dart';

class ProfileSectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const ProfileSectionHeader({
    super.key,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 22, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: isDark ? Colors.white54 : Colors.grey.shade600,
        ),
      ),
    );
  }
}
