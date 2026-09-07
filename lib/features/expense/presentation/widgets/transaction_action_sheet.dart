import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/core/common/utils/sound_service.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/pages/add_expense_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionActionSheet extends StatelessWidget {
  final Expense transaction;
  final String currencyCode;
  final List<Wallet> wallets;

  const TransactionActionSheet({
    super.key,
    required this.transaction,
    required this.currencyCode,
    required this.wallets,
  });

  static Future<void> show({
    required BuildContext context,
    required Expense transaction,
    required String currencyCode,
    required List<Wallet> wallets,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionActionSheet(
        transaction: transaction,
        currencyCode: currencyCode,
        wallets: wallets,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1B29) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.trash, color: Colors.red, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Transaction',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${transaction.title}"? Your wallet balance and calculations will update instantly.',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx); // Close dialog
              Navigator.pop(context); // Close sheet
              context.read<ExpenseBloc>().add(ExpenseDeleteTransaction(transaction.id));
              SoundService.playDelete();
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final isIncome = transaction.type == 'income';

    Wallet? matchedWallet;
    if (transaction.walletId != null) {
      try {
        matchedWallet = wallets.firstWhere((w) => w.id == transaction.walletId);
      } catch (_) {}
    }

    final cardBg = isDark ? const Color(0xFF1E1B29) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Transaction Type & Icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isIncome ? const Color(0xFF10B981) : Colors.redAccent).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  size: 14,
                  color: isIncome ? const Color(0xFF10B981) : Colors.redAccent,
                ),
                const SizedBox(width: 5),
                Text(
                  isIncome ? 'INCOME RECEIVED' : 'EXPENSE SPENT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isIncome ? const Color(0xFF10B981) : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            transaction.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),

          // Amount
          Text(
            (isIncome ? '+ ' : '- ') + CurrencyService.format(transaction.amount, currencyCode),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isIncome ? const Color(0xFF10B981) : Colors.redAccent,
            ),
          ),
          const SizedBox(height: 20),

          // Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _detailRow(
                  label: 'Category',
                  value: transaction.category,
                  icon: Icons.category_rounded,
                  isDark: isDark,
                ),
                Divider(height: 20, color: borderColor),
                _detailRow(
                  label: 'Date',
                  value:
                      '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                  icon: Icons.calendar_today_rounded,
                  isDark: isDark,
                ),
                Divider(height: 20, color: borderColor),
                _detailRow(
                  label: isIncome ? 'Deposited To' : 'Paid From',
                  value: matchedWallet != null
                      ? matchedWallet.name.replaceAll('••', '').replaceAll('•', '').trim()
                      : (transaction.walletId != null ? 'Wallet' : 'Default / Cash'),
                  icon: Icons.account_balance_wallet_rounded,
                  isDark: isDark,
                ),
                if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                  Divider(height: 20, color: borderColor),
                  _detailRow(
                    label: 'Note',
                    value: transaction.notes!,
                    icon: Icons.notes_rounded,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons: Edit & Delete
          Row(
            children: [
              // Delete Button
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFFEF4444).withOpacity(0.14)
                          : const Color(0xFFFEE2E2),
                      foregroundColor: isDark
                          ? const Color(0xFFF87171)
                          : const Color(0xFFDC2626),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFFEF4444).withOpacity(0.28)
                              : const Color(0xFFFCA5A5),
                          width: 1.2,
                        ),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(CupertinoIcons.trash, size: 19),
                    label: const Text(
                      'Delete',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Edit Button
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                      shadowColor: primaryColor.withOpacity(0.35),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddExpensePage(
                            initialType: transaction.type,
                            expenseToEdit: transaction,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit_rounded, size: 19, color: theme.colorScheme.onPrimary),
                    label: Text(
                      'Edit',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
