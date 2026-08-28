import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/common/entities/user.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/balance_card.dart';
import 'package:expense_tracker/features/expense/presentation/pages/connect_wallet_page.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';

class HomeTopHeaderWidget extends StatelessWidget {
  final User user;
  final List<Wallet> wallets;
  final List<Expense> allExpenses;
  final int activeCardIndex;
  final bool isOffline;
  final bool isDark;
  final String greetingText;
  final ValueChanged<int> onPageChanged;

  const HomeTopHeaderWidget({
    super.key,
    required this.user,
    required this.wallets,
    required this.allExpenses,
    required this.activeCardIndex,
    required this.isOffline,
    required this.isDark,
    required this.greetingText,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activeWallet = (wallets.isNotEmpty && activeCardIndex < wallets.length)
        ? wallets[activeCardIndex]
        : (wallets.isNotEmpty ? wallets.first : null);

    final cardBalance = activeWallet != null
        ? activeWallet.balance
        : wallets.fold<double>(0.0, (sum, w) => sum + w.balance);

    final formattedBal = CurrencyService.format(cardBalance, user.currency);

    final now = DateTime.now();
    final thisMonthExpenses = allExpenses.where((e) {
      return e.type == 'expense' &&
          (activeWallet == null || e.walletId == activeWallet.id) &&
          e.date.year == now.year &&
          e.date.month == now.month;
    }).fold<double>(0.0, (sum, e) => sum + e.amount);

    final lastMonth = DateTime(now.year, now.month - 1);
    final lastMonthExpenses = allExpenses.where((e) {
      return e.type == 'expense' &&
          (activeWallet == null || e.walletId == activeWallet.id) &&
          e.date.year == lastMonth.year &&
          e.date.month == lastMonth.month;
    }).fold<double>(0.0, (sum, e) => sum + e.amount);

    double pctChange = 0.0;
    if (lastMonthExpenses > 0) {
      pctChange = ((thisMonthExpenses - lastMonthExpenses) / lastMonthExpenses) * 100;
    } else if (thisMonthExpenses > 0) {
      pctChange = 100.0;
    }
    final isIncrease = pctChange >= 0;
    final pctString = '${pctChange.abs().toStringAsFixed(1)}% this month';
    final cardLabel = activeWallet != null ? activeWallet.name : 'Balance';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isOffline)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.amber.shade900,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Offline Mode. Transactions will auto-sync when online.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greetingText,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Text(
                    user.username?.isNotEmpty == true
                        ? user.username!
                        : user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.sparkles,
                          color: Color(0xFFFDE047),
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Onyx AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Dynamic Balance & Percentage Display
        Center(
          child: Column(
            children: [
              Text(
                cardLabel,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedBal,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isIncrease
                          ? Icons.north_east_rounded
                          : Icons.south_east_rounded,
                      color: isIncrease
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF4ADE80),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pctString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        BalanceCard(
          cardWallets: wallets,
          allTransactions: allExpenses,
          currencyCode: user.currency,
          onCardChanged: onPageChanged,
          onAddCardTap: () {
            Navigator.push(context, ConnectWalletPage.route());
          },
        ),
      ],
    );
  }
}
