import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:expense_tracker/core/common/utils/pdf_report_service.dart';
import 'package:expense_tracker/core/common/utils/animation_helper.dart';

class WalletExportSheet extends StatelessWidget {
  final List<Expense> expenses;
  final List<Wallet> wallets;
  final String userName;
  final String currency;

  const WalletExportSheet({
    super.key,
    required this.expenses,
    required this.wallets,
    required this.userName,
    required this.currency,
  });

  static void show(
    BuildContext context, {
    required List<Expense> expenses,
    required List<Wallet> wallets,
    required String userName,
    required String currency,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => WalletExportSheet(
        expenses: expenses,
        wallets: wallets,
        userName: userName,
        currency: currency,
      ),
    );
  }

  List<Expense> _filterByPeriod(List<Expense> list, String period) {
    if (period == 'All Time' || period == 'all') return list;
    final now = DateTime.now();
    return list.where((tx) {
      if (period == 'Day') {
        return tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.date.day == now.day;
      } else if (period == 'Week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
        final startOfCurrentWeek = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        return tx.date.isAfter(startOfCurrentWeek) ||
            (tx.date.year == startOfCurrentWeek.year &&
                tx.date.month == startOfCurrentWeek.month &&
                tx.date.day == startOfCurrentWeek.day);
      } else if (period == 'Month') {
        return tx.date.year == now.year && tx.date.month == now.month;
      } else if (period == 'Year') {
        return tx.date.year == now.year;
      }
      return true;
    }).toList();
  }

  Future<void> _exportTransactions(
    BuildContext context,
    String period,
  ) async {
    final filteredExpenses = _filterByPeriod(expenses, period);

    if (filteredExpenses.isEmpty) {
      showToast('Cannot export: No transactions found for $period.', isError: true, context: context);
      return;
    }

    final totalBalance = wallets.fold(0.0, (sum, w) => sum + w.balance);

    showExportProgressDialog(context);

    Future.microtask(() async {
      await PdfReportService.generateAndSaveReport(
        transactions: filteredExpenses,
        userName: userName,
        currency: currency,
        period: period,
        type: 'all',
        totalAmount: totalBalance,
        onSuccess: (_) {
          if (!context.mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          AnimationHelper.showSuccess(
            context,
            'Report saved to Downloads & App Reports!',
          );
        },
        onFailed: (err) {
          if (!context.mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          AnimationHelper.showFailed(context, 'Export failed: $err');
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final cardBg = isDark ? const Color(0xFF1E1B29) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final options = [
      {'id': 'Day', 'label': "Today's Statement", 'icon': CupertinoIcons.calendar_today},
      {'id': 'Week', 'label': 'This Week', 'icon': CupertinoIcons.calendar},
      {'id': 'Month', 'label': 'This Month', 'icon': CupertinoIcons.calendar_badge_minus},
      {'id': 'Year', 'label': 'This Year', 'icon': CupertinoIcons.calendar_badge_plus},
      {'id': 'All Time', 'label': 'All Time Statement', 'icon': CupertinoIcons.infinite},
    ];

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Statement Timeframe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((opt) {
                final id = opt['id'] as String;
                final label = opt['label'] as String;
                final icon = opt['icon'] as IconData;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                    ),
                    tileColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: primaryColor, size: 18),
                    ),
                    title: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Icon(
                      CupertinoIcons.chevron_right,
                      size: 16,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _exportTransactions(
                        context,
                        id,
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
