import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyReportsPlaceholder extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color primaryColor;

  const EmptyReportsPlaceholder({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                CupertinoIcons.doc_text_fill,
                size: 56,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Saved Reports Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate PDF statements from Statistics or Wallet page. They will automatically be saved and viewable here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
