import 'dart:ui';

import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/common/utils/sound_service.dart';

class WalletItemTile extends StatelessWidget {
  final Wallet wallet;
  final String currencyCode;

  const WalletItemTile({
    super.key,
    required this.wallet,
    required this.currencyCode,
  });

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
    switch (wallet.type) {
      case 'card':
        return _WalletMeta(
          icon: CupertinoIcons.creditcard_fill,
          label: 'Card',
          gradientColors: isDark
              ? [const Color(0xFF4527A0), const Color(0xFF7B1FA2)]
              : [const Color(0xFF5E35B1), const Color(0xFF9C27B0)],
        );
      case 'bank':
        return _WalletMeta(
          icon: CupertinoIcons.building_2_fill,
          label: 'Bank Account',
          gradientColors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF0D47A1)]
              : [const Color(0xFF1565C0), const Color(0xFF1976D2)],
        );
      default:
        return _WalletMeta(
          icon: CupertinoIcons.device_phone_portrait,
          label: 'Mobile / Other',
          gradientColors: isDark
              ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
              : [const Color(0xFF2E7D32), const Color(0xFF388E3C)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meta = _getMeta(isDark);
    final isNegative = wallet.balance < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isDark
            ? LinearGradient(
                colors: [
                  const Color(0xFF2A273A).withOpacity(0.9),
                  const Color(0xFF1E1B29).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Colors.white,
                  const Color(0xFFF8F9FA),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : Colors.black.withOpacity(0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon block
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: meta.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: meta.gradientColors.first.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(meta.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),

                // Name & Type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        wallet.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta.label,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Balance display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CurrencyService.format(
                        wallet.balance,
                        currencyCode,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: -0.2,
                        color: isNegative
                            ? const Color(0xFFFF6B6B)
                            : (isDark ? const Color(0xFF4ADE80) : Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Balance',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),

                // Cupertino Delete Icon button
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemRed.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.trash,
                      color: CupertinoColors.systemRed,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletMeta {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;

  const _WalletMeta({
    required this.icon,
    required this.label,
    required this.gradientColors,
  });
}
