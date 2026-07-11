import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:flutter/material.dart';

class TransactionItemTile extends StatelessWidget {
  final Expense transaction;
  final String currencyCode;
  final bool isDark;

  const TransactionItemTile({
    super.key,
    required this.transaction,
    required this.currencyCode,
    required this.isDark,
  });

  String _getCategoryIcon(String category, String title) {
    final lowerTitle = title.toLowerCase();
    final lowerCat = category.toLowerCase();

    if (lowerTitle.contains('starbucks')) {
      return 'assets/images/expense_types/shopping-bag.png';
    }
    if (lowerTitle.contains('youtube')) {
      return 'assets/images/expense_types/youtube.png';
    }
    if (lowerTitle.contains('netflix')) {
      return 'assets/images/expense_types/netflix.png';
    }
    if (lowerTitle.contains('spotify')) {
      return 'assets/images/expense_types/spotify.png';
    }
    if (lowerTitle.contains('bkash')) {
      return 'assets/images/expense_types/bKash.png';
    }
    if (lowerTitle.contains('nagad')) {
      return 'assets/images/expense_types/nagad-payment.png';
    }
    if (lowerTitle.contains('rocket')) {
      return 'assets/images/expense_types/rocket-pay.png';
    }
    if (lowerTitle.contains('upay')) {
      return 'assets/images/expense_types/upay-pay.png';
    }
    if (lowerTitle.contains('nexus')) {
      return 'assets/images/expense_types/nexus-pay.png';
    }
    if (lowerTitle.contains('visa')) {
      return 'assets/images/expense_types/visa.png';
    }
    if (lowerTitle.contains('fiverr')) {
      return 'assets/images/expense_types/fiverr.png';
    }
    if (lowerTitle.contains('upwork')) {
      return 'assets/images/expense_types/upwork.png';
    }
    if (lowerTitle.contains('facebook')) {
      return 'assets/images/expense_types/facebook.png';
    }
    if (lowerTitle.contains('instagram')) {
      return 'assets/images/expense_types/instagram.png';
    }
    if (lowerTitle.contains('linkedin')) {
      return 'assets/images/expense_types/linkedin.png';
    }
    if (lowerTitle.contains('gp') || lowerTitle.contains('grameenphone')) {
      return 'assets/images/expense_types/grameenphone-top-up.png';
    }
    if (lowerTitle.contains('robi')) {
      return 'assets/images/expense_types/robi-top-up.png';
    }
    if (lowerTitle.contains('airtel')) {
      return 'assets/images/expense_types/airtel-top-up.png';
    }
    if (lowerTitle.contains('banglalink')) {
      return 'assets/images/expense_types/banglalink-top-up.png';
    }
    if (lowerTitle.contains('teletalk')) {
      return 'assets/images/expense_types/teletalk-top-up.png';
    }
    if (lowerTitle.contains('telecharge')) {
      return 'assets/images/expense_types/teletalk-top-up.png';
    }

    if (lowerCat.contains('food') ||
        lowerCat.contains('restaurant') ||
        lowerCat.contains('dining')) {
      return 'assets/images/expense_types/shopping-bag.png';
    }
    if (lowerCat.contains('shopping') ||
        lowerCat.contains('grocer') ||
        lowerCat.contains('merch')) {
      return 'assets/images/expense_types/shopping-bag.png';
    }
    if (lowerCat.contains('health') ||
        lowerCat.contains('medical') ||
        lowerCat.contains('doctor')) {
      return 'assets/images/expense_types/stethoscope.png';
    }
    if (lowerCat.contains('transport') ||
        lowerCat.contains('travel') ||
        lowerCat.contains('ride') ||
        lowerCat.contains('fuel')) {
      return 'assets/images/expense_types/destination.png';
    }
    if (lowerCat.contains('social') ||
        lowerCat.contains('ent') ||
        lowerCat.contains('media')) {
      return 'assets/images/expense_types/social-media.png';
    }
    if (lowerCat.contains('salary') ||
        lowerCat.contains('income') ||
        lowerCat.contains('freelance')) {
      return 'assets/images/expense_types/freelance.png';
    }

    return 'assets/images/expense_types/others_pay.png';
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final iconPath = _getCategoryIcon(transaction.category, transaction.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              iconPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? Colors.green : Colors.red,
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.category} • ${transaction.date.day}/${transaction.date.month}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            (isIncome ? '+ ' : '- ') +
                CurrencyService.format(transaction.amount, currencyCode),
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
