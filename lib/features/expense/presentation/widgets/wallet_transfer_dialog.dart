import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/core/common/utils/animation_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletTransferDialog extends StatefulWidget {
  final List<Wallet> wallets;
  final String userId;

  const WalletTransferDialog({
    super.key,
    required this.wallets,
    required this.userId,
  });

  static void show(BuildContext context, List<Wallet> wallets, String userId) {
    if (wallets.length < 2) {
      Fluttertoast.showToast(
        msg: 'You need at least 2 wallets to transfer funds.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => WalletTransferDialog(
        wallets: wallets,
        userId: userId,
      ),
    );
  }

  @override
  State<WalletTransferDialog> createState() => _WalletTransferDialogState();
}

class _WalletTransferDialogState extends State<WalletTransferDialog> {
  late Wallet fromWallet;
  late Wallet toWallet;
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fromWallet = widget.wallets.first;
    toWallet = widget.wallets[1];
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1B24) : Colors.white,
      title: const Text(
        'Transfer Funds',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'From Wallet',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Wallet>(
              initialValue: fromWallet,
              dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              items: widget.wallets.map((w) {
                return DropdownMenuItem(value: w, child: Text(w.name));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    fromWallet = val;
                    if (fromWallet == toWallet) {
                      toWallet = widget.wallets.firstWhere((w) => w != fromWallet);
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'To Wallet',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Wallet>(
              initialValue: toWallet,
              dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              items: widget.wallets.where((w) => w != fromWallet).map((w) {
                return DropdownMenuItem(value: w, child: Text(w.name));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => toWallet = val);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Amount',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(hintText: '0.00'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
            if (amount <= 0) {
              Fluttertoast.showToast(msg: 'Enter a valid amount');
              return;
            }

            final expenseBloc = context.read<ExpenseBloc>();

            final debitTx = Expense(
              id: '',
              userId: widget.userId,
              title: 'Transfer to ${toWallet.name}',
              amount: amount,
              date: DateTime.now(),
              type: 'expense',
              category: 'Transfer',
              walletId: fromWallet.id,
            );

            final creditTx = Expense(
              id: '',
              userId: widget.userId,
              title: 'Transfer from ${fromWallet.name}',
              amount: amount,
              date: DateTime.now(),
              type: 'income',
              category: 'Transfer',
              walletId: toWallet.id,
            );

            expenseBloc.add(ExpenseAddTransaction(debitTx));
            expenseBloc.add(ExpenseAddTransaction(creditTx));

            Navigator.pop(context);
            AnimationHelper.showSuccess(
              context,
              'Transfer completed successfully!',
            );
            expenseBloc.add(ExpenseFetchAll());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Transfer'),
        ),
      ],
    );
  }
}
