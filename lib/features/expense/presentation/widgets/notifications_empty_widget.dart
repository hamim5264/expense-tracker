import 'package:flutter/material.dart';

class NotificationsEmptyWidget extends StatelessWidget {
  final bool isDark;

  const NotificationsEmptyWidget({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2245) : const Color(0xFFF0E7FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 44,
                color: Color(0xFF8152D5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'All caught up!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF201B38),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No notifications in this category right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF77728E),
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

