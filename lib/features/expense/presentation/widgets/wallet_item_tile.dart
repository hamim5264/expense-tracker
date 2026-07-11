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
          label: 'Credit / Debit Card',
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

    final glassColor = isDark
        ? Colors.white.withAlpha(18)
        : Colors.white.withAlpha(190);
    final glassBorder = isDark
        ? Colors.white.withAlpha(35)
        : Colors.white.withAlpha(220);
    final shadowColor = isDark
        ? Colors.black.withAlpha(80)
        : Colors.black.withAlpha(20);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: glassColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: glassBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: meta.gradientColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: meta.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: meta.gradientColors.first.withAlpha(80),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(meta.icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(height: 3),
                            Text(
                              meta.label,
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black45,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyService.format(
                              wallet.balance,
                              currencyCode,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Balance',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: () => _confirmDelete(context),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemRed.withAlpha(220),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.systemRed.withAlpha(80),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.minus,
                            color: Colors.white,
                            size: 15,
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
