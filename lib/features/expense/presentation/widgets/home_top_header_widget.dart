import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:expense_tracker/core/common/entities/user.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/balance_card.dart';
import 'package:expense_tracker/features/expense/presentation/pages/connect_wallet_page.dart';
import 'package:expense_tracker/features/expense/presentation/pages/onyx_ai_page.dart';
import 'package:expense_tracker/core/routing/app_router.dart';
import 'package:expense_tracker/core/common/utils/notification_service.dart';
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

    // Properly handle year rollover (e.g. January -> December of previous year)
    final lastMonthDate = DateTime(now.year, now.month - 1, 1);
    final lastMonthExpenses = allExpenses.where((e) {
      return e.type == 'expense' &&
          (activeWallet == null || e.walletId == activeWallet.id) &&
          e.date.year == lastMonthDate.year &&
          e.date.month == lastMonthDate.month;
    }).fold<double>(0.0, (sum, e) => sum + e.amount);

    double pctChange = 0.0;
    if (lastMonthExpenses > 0) {
      pctChange = ((thisMonthExpenses - lastMonthExpenses) / lastMonthExpenses) * 100;
    } else if (thisMonthExpenses > 0) {
      // Only show 100% if there are actual expenses this month with none last month
      pctChange = 100.0;
    }
    // If both months have zero expenses, pctChange stays 0.0
    final isIncrease = pctChange >= 0;
    final pctString = '${pctChange.abs().toStringAsFixed(1)}% this month';

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
                OnyxAiHeaderButton(
                  onTap: () {
                    Navigator.push(context, OnyxAiPage.route());
                  },
                ),
                const SizedBox(width: 12),
                AnimatedBuilder(
                  animation: NotificationService(),
                  builder: (context, _) {
                    final unread = NotificationService().unreadCount;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.notifications,
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Icon(
                              CupertinoIcons.bell,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          if (unread > 0)
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 1.5,
                                  ),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  unread > 9 ? '9+' : '$unread',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
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
        const SizedBox(height: 36),

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

class OnyxAiHeaderButton extends StatefulWidget {
  final VoidCallback onTap;

  const OnyxAiHeaderButton({super.key, required this.onTap});

  @override
  State<OnyxAiHeaderButton> createState() => _OnyxAiHeaderButtonState();
}

class _OnyxAiHeaderButtonState extends State<OnyxAiHeaderButton> {
  int _greetingIndex = 0;
  Timer? _timer;
  final List<String> _greetings = const [
    'Hi ✨',
    'Hello 👋',
    "Let's talk 💬",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _greetingIndex = (_greetingIndex + 1) % _greetings.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Bot Icon Container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.35),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Lottie.asset(
              'assets/animations/onyx_ai.json',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.sparkles,
                    color: Color(0xFFFDE047),
                    size: 20,
                  ),
                );
              },
            ),
          ),

          // Speech Bubble Floating at Top Corner
          Positioned(
            top: -10,
            right: -2,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                    ),
                    alignment: Alignment.bottomRight,
                    child: child,
                  ),
                );
              },
              child: ClipRRect(
                key: ValueKey<int>(_greetingIndex),
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.55),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.16),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _greetings[_greetingIndex],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
