import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyNotificationsPlaceholder extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color primaryColor;

  const EmptyNotificationsPlaceholder({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.bell_slash,
                  size: 56,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'All caught up!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'No new notifications at the moment.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
