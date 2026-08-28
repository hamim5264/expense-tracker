import 'package:flutter/material.dart';

class EmptyTransactionsPlaceholder extends StatelessWidget {
  const EmptyTransactionsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.12),
                border: Border.all(
                  color: primaryColor.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 38,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Transactions Yet',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Start tracking your finances by\nadding your first income or expense!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
