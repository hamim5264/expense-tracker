import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;

  const SocialButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? Colors.grey[800]! : const Color(0xFFE8ECF4),
            ),
            borderRadius: BorderRadius.circular(8),
            color: isDark ? Colors.grey[900] : Colors.white,
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}
