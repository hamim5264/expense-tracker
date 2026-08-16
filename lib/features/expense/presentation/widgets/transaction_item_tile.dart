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
        lowerCat.contains('dining') ||
        lowerCat.contains('restaurant')) {
      return 'assets/images/expense_types/shopping-bag.png';
    }
    if (lowerCat.contains('grocer')) {
      return 'assets/images/expense_types/shopping-bag.png';
    }
    if (lowerCat.contains('shopping')) {
      return 'assets/images/expense_types/online-shopping.png';
    }
    if (lowerCat.contains('health') ||
        lowerCat.contains('medical') ||
        lowerCat.contains('doctor')) {
      return 'assets/images/expense_types/cardiogram.png';
    }
    if (lowerCat.contains('stethoscope')) {
      return 'assets/images/expense_types/stethoscope.png';
    }
    if (lowerCat.contains('travel') || lowerCat.contains('agency')) {
      return 'assets/images/expense_types/travel-agency.png';
    }
    if (lowerCat.contains('transport') ||
        lowerCat.contains('ride') ||
        lowerCat.contains('fuel') ||
        lowerCat.contains('destination')) {
      return 'assets/images/expense_types/destination.png';
    }
    if (lowerCat.contains('education') ||
        lowerCat.contains('investment') ||
        lowerCat.contains('dividend') ||
        lowerCat.contains('symbol')) {
      return 'assets/images/expense_types/symbols.png';
    }
    if (lowerCat.contains('bill') ||
        lowerCat.contains('utilit') ||
        lowerCat.contains('phone') ||
        lowerCat.contains('smart')) {
      return 'assets/images/expense_types/smartphone.png';
    }
    if (lowerCat.contains('subscription') ||
        lowerCat.contains('premium') ||
        lowerCat.contains('insurance') ||
        lowerCat.contains('rent') ||
        lowerCat.contains('home') ||
        lowerCat.contains('bonus')) {
      return 'assets/images/expense_types/premium.png';
    }
    if (lowerCat.contains('salary') ||
        lowerCat.contains('income') ||
        lowerCat.contains('freelance')) {
      return 'assets/images/expense_types/freelance.png';
    }
    if (lowerCat.contains('social') ||
        lowerCat.contains('ent') ||
        lowerCat.contains('media') ||
        lowerCat.contains('family') ||
        lowerCat.contains('gift') ||
        lowerCat.contains('donation')) {
      return 'assets/images/expense_types/social.png';
    }

    return 'assets/images/expense_types/others_pay.png';
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final iconPath = _getCategoryIcon(transaction.category, transaction.title);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              iconPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? Colors.green : Colors.red,
                  size: 20,
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.category} • ${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _formatTime(transaction.date),
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: isIncome
                  ? const Color(0xFF22C55E).withOpacity(0.12)
                  : const Color(0xFFEF4444).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isIncome
                    ? const Color(0xFF22C55E).withOpacity(0.8)
                    : const Color(0xFFEF4444).withOpacity(0.8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isIncome
                      ? const Color(0xFF22C55E).withOpacity(0.15)
                      : const Color(0xFFEF4444).withOpacity(0.15),
                  blurRadius: 6,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: Text(
              (isIncome ? '+ ' : '- ') +
                  CurrencyService.format(transaction.amount, currencyCode),
              style: TextStyle(
                color: isIncome
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
