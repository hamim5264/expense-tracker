import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:flutter/material.dart';

class SmsDetectedCard extends StatelessWidget {
  final Expense item;
  final String currencyCode;
  final bool isDark;
  final VoidCallback onSync;
  final VoidCallback onDiscard;

  const SmsDetectedCard({
    super.key,
    required this.item,
    required this.currencyCode,
    required this.isDark,
    required this.onSync,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4F378A);

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                CurrencyService.format(item.amount, currencyCode),
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Category: ${item.category}',
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 24),
                ),
                onPressed: onDiscard,
                child: const Text(
                  'Discard',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(60, 28),
                ),
                onPressed: onSync,
                child: const Text(
                  'Sync',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
