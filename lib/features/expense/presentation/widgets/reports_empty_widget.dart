import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReportsEmptyWidget extends StatelessWidget {
  final String currentFilter;
  final VoidCallback onGenerate;

  const ReportsEmptyWidget({
    super.key,
    required this.currentFilter,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF563294);
    final circleBg = isDark ? const Color(0xFF2B233D) : const Color(0xFFF0E7FF);
    final titleColor = isDark ? Colors.white : const Color(0xFF211B38);
    final subColor = isDark ? const Color(0xFFA69EB8) : const Color(0xFF817A9B);

    final title = currentFilter == 'All'
        ? 'No Reports Yet'
        : 'No $currentFilter Reports';

    final message = currentFilter == 'All'
        ? 'Generate your first financial report to keep track of your money and export statements.'
        : 'No statements found matching "$currentFilter". You can generate one below.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: circleBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Icon(
                CupertinoIcons.doc_text,
                color: primaryColor,
                size: 50,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: titleColor,
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: subColor,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: onGenerate,
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor.withOpacity(0.4), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(CupertinoIcons.plus, size: 18),
              label: const Text(
                'Generate Report Now',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

