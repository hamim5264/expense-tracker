import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/presentation/pages/connect_wallet_page.dart';
import 'package:flutter/material.dart';

class TransactionFormCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final DateTime selectedDate;
  final String transactionType;
  final String? selectedWalletId;
  final List<Wallet> wallets;
  final String currencySymbol;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onPickDate;
  final ValueChanged<String?> onWalletChanged;

  const TransactionFormCard({
    super.key,
    required this.nameController,
    required this.amountController,
    required this.selectedDate,
    required this.transactionType,
    required this.selectedWalletId,
    required this.wallets,
    required this.currencySymbol,
    required this.isDark,
    required this.primaryColor,
    required this.onPickDate,
    required this.onWalletChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E1B29) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;
    final labelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
      color: isDark ? Colors.white54 : Colors.grey.shade600,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // NAME FIELD
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NAME', style: labelStyle),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        hintText: transactionType == 'expense' ? 'e.g. Netflix' : 'e.g. Salary Pay',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white30 : Colors.grey.shade400,
                        ),
                        fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade50,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // AMOUNT FIELD
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AMOUNT', style: labelStyle),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : primaryColor,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        prefixText: '$currencySymbol ',
                        prefixStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : primaryColor,
                        ),
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white30 : Colors.grey.shade400,
                        ),
                        fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade50,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              // DATE FIELD
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DATE', style: labelStyle),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onPickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_rounded,
                              color: primaryColor.withOpacity(0.8),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),
              if (wallets.isNotEmpty) ...[
                // WALLET DROPDOWN
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            transactionType == 'expense'
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 12,
                            color: transactionType == 'expense'
                                ? Colors.redAccent
                                : const Color(0xFF10B981),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            transactionType == 'expense'
                                ? 'PAID FROM'
                                : 'DEPOSIT TO',
                            style: labelStyle.copyWith(
                              color: transactionType == 'expense'
                                  ? (isDark ? Colors.redAccent.shade100 : Colors.red.shade700)
                                  : (isDark ? const Color(0xFF34D399) : Colors.green.shade700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedWalletId,
                        isDense: true,
                        isExpanded: true,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        dropdownColor: isDark ? const Color(0xFF1E1B29) : Colors.white,
                        items: wallets.map((wallet) {
                          final cleanName = wallet.name.replaceAll('••', '').replaceAll('•', '').trim();
                          final isCash = (wallet.details['is_cash'] == true) ||
                              wallet.name.toLowerCase().contains('cash');
                          final isCard = wallet.type == 'card';
                          return DropdownMenuItem<String>(
                            value: wallet.id,
                            child: Row(
                              children: [
                                Icon(
                                  isCash
                                      ? Icons.payments_rounded
                                      : isCard
                                          ? Icons.credit_card_rounded
                                          : Icons.account_balance_rounded,
                                  size: 15,
                                  color: isCash
                                      ? const Color(0xFF10B981)
                                      : (isDark ? Colors.white70 : Colors.black54),
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    cleanName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: onWalletChanged,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9.5),
                          fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade50,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Fallback button to connect a wallet or cash
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transactionType == 'expense' ? 'PAID FROM' : 'DEPOSIT TO',
                        style: labelStyle,
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ConnectWalletPage(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.4),
                            ),
                            color: primaryColor.withOpacity(0.08),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline_rounded, size: 15, color: primaryColor),
                              const SizedBox(width: 5),
                              Text(
                                '+ Add Wallet',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
