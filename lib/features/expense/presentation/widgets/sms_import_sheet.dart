import 'dart:ui';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class SmsImportSheet extends StatefulWidget {
  final String userId;
  final List<Wallet> wallets;

  const SmsImportSheet({
    super.key,
    required this.userId,
    required this.wallets,
  });

  @override
  State<SmsImportSheet> createState() => _SmsImportSheetState();
}

class _SmsImportSheetState extends State<SmsImportSheet> {
  final SmsQuery _query = SmsQuery();
  List<Expense> _parsedExpenses = [];
  final List<Expense> _selectedExpenses = [];
  final Map<String, double> _manualAmounts = {};
  final Map<String, String> _smsBodies = {};
  String? _selectedWalletId;
  bool _isLoading = false;
  bool _showAllInbox = false;

  @override
  void initState() {
    super.initState();
    if (widget.wallets.isNotEmpty) {
      _selectedWalletId = widget.wallets.first.id;
    }
    _loadAndParseSms();
  }

  Future<void> _loadAndParseSms() async {
    setState(() => _isLoading = true);
    try {
      final messages = await _query.querySms(kinds: [SmsQueryKind.inbox]);

      final List<Expense> allList = [];
      final amountRegex = RegExp(
        r'(?:bdt|tk|\$|usd|debited|charged|spent)\s*([\d,]+(?:\.\d{1,2})?)|([\d,]+(?:\.\d{1,2})?)\s*(?:bdt|tk|\$|usd|taka)',
        caseSensitive: false,
      );

      for (var msg in messages) {
        final body = msg.body ?? '';
        final lowerBody = body.toLowerCase();
        final idStr = msg.id.toString();

        _smsBodies[idStr] = body;

        final isTx =
            lowerBody.contains('debited') ||
            lowerBody.contains('spent') ||
            lowerBody.contains('payment') ||
            lowerBody.contains('charged') ||
            lowerBody.contains('purchase') ||
            lowerBody.contains('transaction');

        double amount = 0.0;
        final match = amountRegex.firstMatch(body);
        if (match != null) {
          final amountStr = match.group(1) ?? match.group(2);
          if (amountStr != null) {
            final cleanedVal = amountStr.replaceAll(',', '');
            amount = double.tryParse(cleanedVal) ?? 0.0;
          }
        }

        String category = 'Others';
        if (lowerBody.contains('food') || lowerBody.contains('restaurant')) {
          category = 'Food';
        } else if (lowerBody.contains('shop') || lowerBody.contains('grocer')) {
          category = 'Shopping';
        }

        String merchant = msg.sender ?? 'SMS Alert';
        if (merchant.length > 25) merchant = merchant.substring(0, 25);

        final exp = Expense(
          id: idStr,
          userId: widget.userId,
          title: merchant,
          amount: amount,
          date: msg.date ?? DateTime.now(),
          type: 'expense',
          category: category,
        );

        if (_showAllInbox) {
          allList.add(exp);
        } else {
          if (isTx && amount > 0) {
            allList.add(exp);
          }
        }
      }

      setState(() {
        _parsedExpenses = allList;
        _selectedExpenses.clear();
        _selectedExpenses.addAll(
          allList.where(
            (e) => (e.amount > 0 || _manualAmounts.containsKey(e.id)),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: 'Error reading SMS: $e');
    }
  }

  void _toggleSelect(Expense exp) {
    setState(() {
      if (_selectedExpenses.contains(exp)) {
        _selectedExpenses.remove(exp);
      } else {
        _selectedExpenses.add(exp);
      }
    });
  }

  void _showAmountDialog(Expense exp) {
    final controller = TextEditingController(
      text: (_manualAmounts[exp.id] ?? (exp.amount > 0 ? exp.amount : ''))
          .toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Amount (BDT)'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: '0.00'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final amt = double.tryParse(controller.text) ?? 0.0;
                if (amt > 0) {
                  setState(() {
                    _manualAmounts[exp.id] = amt;
                    if (!_selectedExpenses.contains(exp)) {
                      _selectedExpenses.add(exp);
                    }
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _importSelected() {
    if (_selectedExpenses.isEmpty) {
      Fluttertoast.showToast(msg: 'No transactions selected.');
      return;
    }
    if (_selectedWalletId == null) {
      Fluttertoast.showToast(msg: 'Please connect and select a wallet first.');
      return;
    }

    final bloc = context.read<ExpenseBloc>();
    int count = 0;
    for (var exp in _selectedExpenses) {
      final finalAmt = _manualAmounts[exp.id] ?? exp.amount;
      if (finalAmt <= 0) continue;

      final finalExpense = Expense(
        id: '',
        userId: exp.userId,
        title: exp.title,
        amount: finalAmt,
        date: exp.date,
        type: exp.type,
        category: exp.category,
        walletId: _selectedWalletId,
      );
      bloc.add(ExpenseAddTransaction(finalExpense));
      count++;
    }

    Fluttertoast.showToast(msg: 'Successfully imported $count transactions!');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final glassBg = isDark
        ? Colors.black.withAlpha(200)
        : Colors.white.withAlpha(225);
    final borderColor = isDark
        ? Colors.white.withAlpha(30)
        : Colors.black.withAlpha(20);
    final textColor = isDark ? Colors.white : Colors.black87;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: glassBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SMS Expense Import',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (_parsedExpenses.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (_selectedExpenses.length ==
                              _parsedExpenses.length) {
                            _selectedExpenses.clear();
                          } else {
                            _selectedExpenses.clear();
                            _selectedExpenses.addAll(_parsedExpenses);
                          }
                        });
                      },
                      child: Text(
                        _selectedExpenses.length == _parsedExpenses.length
                            ? 'Deselect All'
                            : 'Select All',
                        style: const TextStyle(color: Color(0xFF4F378A)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Show all messages manually',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withAlpha(200),
                    ),
                  ),
                  Switch(
                    value: _showAllInbox,
                    activeThumbColor: const Color(0xFF4F378A),
                    onChanged: (val) {
                      setState(() {
                        _showAllInbox = val;
                      });
                      _loadAndParseSms();
                    },
                  ),
                ],
              ),
            ),
            if (widget.wallets.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Text(
                      'Import to Wallet: ',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedWalletId,
                        items: widget.wallets.map((wallet) {
                          return DropdownMenuItem<String>(
                            value: wallet.id,
                            child: Text(wallet.name),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedWalletId = val),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _parsedExpenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sms_failed_rounded,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No SMS messages found.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _parsedExpenses.length,
                      itemBuilder: (context, index) {
                        final exp = _parsedExpenses[index];
                        final isSelected = _selectedExpenses.contains(exp);
                        final amount = _manualAmounts[exp.id] ?? exp.amount;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4F378A)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: CheckboxListTile(
                              value: isSelected,
                              activeColor: const Color(0xFF4F378A),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (_) => _toggleSelect(exp),
                              title: Text(
                                exp.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${exp.category} • ${_formatDate(exp.date)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _smsBodies[exp.id] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              secondary: GestureDetector(
                                onTap: () => _showAmountDialog(exp),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: amount > 0
                                        ? Colors.redAccent.withAlpha(25)
                                        : Colors.grey.withAlpha(40),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        amount > 0
                                            ? '-${CurrencyService.format(amount, "BDT")}'
                                            : 'Enter Amt',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: amount > 0
                                              ? Colors.redAccent
                                              : Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.edit_rounded,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F378A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _importSelected,
                  child: Text(
                    'Import Selected (${_selectedExpenses.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
