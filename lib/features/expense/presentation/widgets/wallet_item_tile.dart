import 'dart:ui';

import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/pages/add_expense_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/common/utils/sound_service.dart';
import 'package:expense_tracker/core/common/utils/theme_service.dart';
import 'package:expense_tracker/core/common/utils/show_snackbar.dart';

class WalletItemTile extends StatelessWidget {
  final Wallet wallet;
  final String currencyCode;

  const WalletItemTile({
    super.key,
    required this.wallet,
    required this.currencyCode,
  });

  void _showEditDialog(BuildContext context) {
    final bloc = context.read<ExpenseBloc>();
    final cleanWalletName = wallet.name.replaceAll('••', '').replaceAll('•', '').trim();
    final nameController = TextEditingController(text: cleanWalletName);

    // Calculate transactions net for this wallet
    List<Expense> walletExpenses = [];
    final state = bloc.state;
    if (state is ExpenseSuccess) {
      walletExpenses = state.expenses.where((e) => e.walletId == wallet.id).toList();
    }
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    for (final tx in walletExpenses) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }
    final netTx = totalIncome - totalExpense;

    double initialBalance = (wallet.details['initial_balance'] as num?)?.toDouble() ?? (wallet.balance - netTx);
    // Legacy auto-heal check if previously corrupted by buggy update:
    if (wallet.details['version'] == null &&
        netTx != 0 &&
        wallet.details['initial_balance'] != null &&
        (initialBalance - wallet.balance).abs() > 0.01 &&
        (initialBalance - (wallet.balance - netTx)).abs() < 0.01) {
      initialBalance = wallet.balance;
    }

    final balanceController = TextEditingController(
      text: initialBalance.toStringAsFixed(2),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) {
          final enteredInitial = double.tryParse(balanceController.text.trim()) ?? 0.0;
          final calculatedBalance = enteredInitial + netTx;

          return ValueListenableBuilder<Color>(
            valueListenable: ThemeService.primaryColorNotifier,
            builder: (context, primaryColor, _) {
              final cardBg = isDark ? const Color(0xFF1E1B29) : Colors.white;
              final textColor = isDark ? Colors.white : Colors.black87;
              final subTextColor = isDark ? Colors.white60 : Colors.black54;
              final fieldBg = isDark ? const Color(0xFF2A273A) : Colors.grey.shade100;
              final inputTextColor = isDark ? Colors.white : Colors.black87;
              final balanceTextColor = isDark ? const Color(0xFF4ADE80) : primaryColor;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar
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
                        const SizedBox(height: 18),

                        // Title Header with Icon
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.pencil_outline,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Edit Wallet / Funds',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Update wallet name or base starting balance',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Name Field
                        Text(
                          'Wallet / Card Name',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: inputTextColor,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              CupertinoIcons.creditcard,
                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                              size: 18,
                            ),
                            hintText: 'Wallet Name',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            filled: true,
                            fillColor: fieldBg,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: primaryColor, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Starting Balance Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Starting / Base Balance ($currencyCode)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            Text(
                              'Initial funds before transactions',
                              style: TextStyle(
                                fontSize: 11,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: balanceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => setModalState(() {}),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: balanceTextColor,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    CurrencyService.getSymbol(currencyCode),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: balanceTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 0,
                            ),
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            filled: true,
                            fillColor: fieldBg,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: primaryColor, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Live Dynamic Breakdown Preview
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.04)
                                : primaryColor.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : primaryColor.withOpacity(0.12),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Base Starting Funds',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    CurrencyService.format(enteredInitial, currencyCode),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Incomes Recorded',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    '+${CurrencyService.format(totalIncome, currencyCode)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Expenses Recorded',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    '-${CurrencyService.format(totalExpense, currencyCode)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Divider(
                                  height: 1,
                                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Resulting Balance',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    CurrencyService.format(calculatedBalance, currencyCode),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: calculatedBalance < 0
                                          ? const Color(0xFFFF5252)
                                          : (isDark
                                              ? const Color(0xFF4ADE80)
                                              : const Color(0xFF16A34A)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Quick Deposit / Add Funds Shortcut
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              AddExpensePage.route(
                                initialType: 'income',
                              ),
                            ).then((_) => bloc.add(ExpenseFetchAll()));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF10B981).withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.plus_circle_fill,
                                  size: 16,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Deposit / Add Funds as Income',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Action buttons (Cancel & Save)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.grey.shade300,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor,
                                      primaryColor.withOpacity(0.85),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () {
                                    final newName = nameController.text.trim();
                                    final newStartingBalance =
                                        double.tryParse(balanceController.text.trim()) ??
                                            initialBalance;

                                    if (newName.isEmpty) return;

                                    final detailsCopy = Map<String, dynamic>.from(wallet.details);
                                    detailsCopy['initial_balance'] = newStartingBalance;
                                    detailsCopy['version'] = 2;

                                    final updatedWallet = Wallet(
                                      id: wallet.id,
                                      userId: wallet.userId,
                                      name: newName,
                                      type: wallet.type,
                                      balance: newStartingBalance,
                                      details: detailsCopy,
                                      createdAt: wallet.createdAt,
                                    );

                                    SoundService.playSuccess();
                                    bloc.add(ExpenseUpdateWallet(updatedWallet));
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final bloc = context.read<ExpenseBloc>();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text(
          'Remove Wallet',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        message: Text(
          'Are you sure you want to remove "${wallet.name}"?\nThis action cannot be undone.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              SoundService.playSuccess();
              bloc.add(ExpenseDeleteWallet(wallet.id));
              showToast('Wallet "${wallet.name}" removed successfully', context: context);
            },
            child: const Text('Remove'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  _WalletMeta _getMeta(bool isDark) {
    final nameLower = wallet.name.toLowerCase();
    final providerLower = (wallet.details['provider'] ?? '').toString().toLowerCase();
    final bankLower = (wallet.details['bank_name'] ?? '').toString().toLowerCase();
    final rawNum = (wallet.details['card_number'] ?? '').toString().replaceAll(RegExp(r'\s+'), '');
    final combined = '$nameLower $providerLower $bankLower';

    String? assetPath;
    Color accentColor = const Color(0xFF6366F1);
    List<Color> cardGradients;
    String brandLabel = wallet.type == 'card' ? 'Card' : (wallet.type == 'bank' ? 'Bank Account' : 'Mobile Wallet');

    if (rawNum.startsWith('4') || combined.contains('visa')) {
      assetPath = 'assets/images/expense_types/visa.png';
      accentColor = const Color(0xFF38BDF8);
      brandLabel = 'Visa';
      cardGradients = isDark
          ? [const Color(0xFF0F172A), const Color(0xFF1E3A8A), const Color(0xFF1E293B)]
          : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE), const Color(0xFFF8FAFC)];
    } else if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(rawNum) || combined.contains('mastercard') || combined.contains('master')) {
      assetPath = 'assets/images/expense_types/card.png';
      accentColor = const Color(0xFFF87171);
      brandLabel = 'Mastercard';
      cardGradients = isDark
          ? [const Color(0xFF311218), const Color(0xFF450A0A), const Color(0xFF18181B)]
          : [const Color(0xFFFEF2F2), const Color(0xFFFEE2E2), const Color(0xFFFAF5FF)];
    } else if (RegExp(r'^3[47]').hasMatch(rawNum) || combined.contains('american') || combined.contains('express') || combined.contains('amex')) {
      assetPath = 'assets/images/expense_types/american-express.png';
      accentColor = const Color(0xFF2DD4BF);
      brandLabel = 'Amex';
      cardGradients = isDark
          ? [const Color(0xFF064E3B), const Color(0xFF022C22), const Color(0xFF0F172A)]
          : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7), const Color(0xFFFAFAF9)];
    } else if (RegExp(r'^(6011|65)').hasMatch(rawNum) || combined.contains('discover')) {
      assetPath = 'assets/images/expense_types/card.png';
      accentColor = const Color(0xFFFB923C);
      brandLabel = 'Discover';
      cardGradients = isDark
          ? [const Color(0xFF431407), const Color(0xFF2A0800), const Color(0xFF18181B)]
          : [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5), const Color(0xFFFAFAF9)];
    } else if (combined.contains('bkash')) {
      assetPath = 'assets/images/expense_types/bKash.png';
      accentColor = const Color(0xFFE2136E);
      brandLabel = 'bKash Wallet';
      cardGradients = isDark
          ? [const Color(0xFF33081E), const Color(0xFF1E0A24), const Color(0xFF140D26)]
          : [const Color(0xFFFFF0F5), const Color(0xFFFDE8F0), const Color(0xFFF9F5FF)];
    } else if (combined.contains('nagad')) {
      assetPath = 'assets/images/expense_types/nagad-payment.png';
      accentColor = const Color(0xFFF7941D);
      brandLabel = 'Nagad Wallet';
      cardGradients = isDark
          ? [const Color(0xFF3B1800), const Color(0xFF241005), const Color(0xFF180E1B)]
          : [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5), const Color(0xFFFAFAF9)];
    } else if (combined.contains('rocket')) {
      assetPath = 'assets/images/expense_types/rocket-pay.png';
      accentColor = const Color(0xFF8C3694);
      brandLabel = 'Rocket Wallet';
      cardGradients = isDark
          ? [const Color(0xFF2B0A33), const Color(0xFF1D0826), const Color(0xFF130A24)]
          : [const Color(0xFFFAF5FF), const Color(0xFFF3E8FF), const Color(0xFFF8FAFC)];
    } else if (combined.contains('upay')) {
      assetPath = 'assets/images/expense_types/upay-pay.png';
      accentColor = const Color(0xFFFFC72C);
      brandLabel = 'Upay Wallet';
      cardGradients = isDark
          ? [const Color(0xFF302400), const Color(0xFF1F1A08), const Color(0xFF14131A)]
          : [const Color(0xFFFEFCE8), const Color(0xFFFEF08A), const Color(0xFFFAFAF9)];
    } else if (combined.contains('nexus')) {
      assetPath = 'assets/images/expense_types/nexus-pay.png';
      accentColor = const Color(0xFF0072BC);
      brandLabel = 'NexusPay Card';
      cardGradients = isDark
          ? [const Color(0xFF06233B), const Color(0xFF0A1828), const Color(0xFF0E1322)]
          : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE), const Color(0xFFF8FAFC)];
    } else {
      assetPath = wallet.type == 'card'
          ? 'assets/images/expense_types/card.png'
          : wallet.type == 'bank'
              ? 'assets/images/expense_types/atm-card.png'
              : 'assets/images/expense_types/smartphone.png';
      accentColor = isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);
      cardGradients = isDark
          ? [const Color(0xFF231E3D), const Color(0xFF19152B), const Color(0xFF12101F)]
          : [const Color(0xFFF5F3FF), const Color(0xFFEDE9FE), const Color(0xFFFAF9FE)];
    }

    switch (wallet.type) {
      case 'card':
        return _WalletMeta(
          icon: CupertinoIcons.creditcard_fill,
          assetPath: assetPath,
          label: brandLabel,
          accentColor: accentColor,
          gradientColors: cardGradients,
        );
      case 'bank':
        return _WalletMeta(
          icon: CupertinoIcons.building_2_fill,
          assetPath: assetPath,
          label: brandLabel,
          accentColor: accentColor,
          gradientColors: cardGradients,
        );
      default:
        return _WalletMeta(
          icon: CupertinoIcons.device_phone_portrait,
          assetPath: assetPath,
          label: brandLabel,
          accentColor: accentColor,
          gradientColors: cardGradients,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meta = _getMeta(isDark);
    final isNegative = wallet.balance < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: meta.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? meta.accentColor.withOpacity(0.3)
              : meta.accentColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: meta.accentColor.withOpacity(isDark ? 0.25 : 0.12),
            blurRadius: 22,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background glowing accent orb for futuristic mesh effect
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: meta.accentColor.withOpacity(isDark ? 0.25 : 0.15),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: meta.accentColor.withOpacity(isDark ? 0.15 : 0.08),
                ),
              ),
            ),

            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Clean White Glass Container for Brand Logo
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: meta.assetPath != null
                          ? Image.asset(
                              meta.assetPath!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                meta.icon,
                                color: meta.accentColor,
                                size: 24,
                              ),
                            )
                          : Icon(meta.icon, color: meta.accentColor, size: 24),
                    ),
                    const SizedBox(width: 14),

                    // Name & Subtitle (Compact)
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            wallet.name.replaceAll('••', '').replaceAll('•', '').trim(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            meta.label,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : meta.accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Builder(
                            builder: (context) {
                              final cardNum = (wallet.details['card_number'] ?? wallet.details['account_number'] ?? wallet.details['phone']) as String?;
                              final last4 = cardNum != null && cardNum.length > 4
                                  ? '•••• ${cardNum.substring(cardNum.length - 4)}'
                                  : (cardNum != null && cardNum.isNotEmpty ? '•••• $cardNum' : null);
                              if (last4 == null) return const SizedBox.shrink();

                              return Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  last4,
                                  style: TextStyle(
                                    color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Balance Display (Prominent & Large)
                    Expanded(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Balance Column
                          Flexible(
                            child: GestureDetector(
                              onTap: () => _showEditDialog(context),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      CurrencyService.format(
                                        wallet.balance,
                                        currencyCode,
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        letterSpacing: -0.4,
                                        color: isNegative
                                            ? const Color(0xFFFF5252)
                                            : (isDark
                                                ? const Color(0xFF4ADE80)
                                                : const Color(0xFF16A34A)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons.pencil_circle_fill,
                                          size: 10,
                                          color: meta.accentColor,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Balance',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Edit Button
                          GestureDetector(
                            onTap: () => _showEditDialog(context),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: meta.accentColor.withOpacity(
                                  isDark ? 0.2 : 0.12,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.pencil,
                                color: isDark
                                    ? Colors.white
                                    : meta.accentColor,
                                size: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Delete Button
                          GestureDetector(
                            onTap: () => _confirmDelete(context),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemRed.withOpacity(
                                  isDark ? 0.2 : 0.12,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.trash,
                                color: CupertinoColors.systemRed,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletMeta {
  final IconData icon;
  final String? assetPath;
  final String label;
  final Color accentColor;
  final List<Color> gradientColors;

  const _WalletMeta({
    required this.icon,
    this.assetPath,
    required this.label,
    required this.accentColor,
    required this.gradientColors,
  });
}
