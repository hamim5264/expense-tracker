import 'dart:ui';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/core/common/utils/animation_helper.dart';
import 'package:expense_tracker/core/common/utils/sms_import_tracker.dart';
import 'package:expense_tracker/core/common/utils/sms_parser.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  final List<Expense> _parsedExpenses = [];
  final List<Expense> _selectedExpenses = [];
  final Map<String, double> _manualAmounts = {};
  final Map<String, String> _smsBodies = {};
  String? _selectedWalletId;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.wallets.isNotEmpty) {
      _selectedWalletId = widget.wallets.first.id;
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

  void _showPasteSmsDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = TextEditingController();

    final glassBg = isDark
        ? Colors.black.withOpacity(0.75)
        : Colors.white.withOpacity(0.85);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.08);

    showDialog(
      context: context,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Container(
              padding: const EdgeInsets.all(22.0),
              decoration: BoxDecoration(
                color: glassBg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.paste_rounded, color: theme.primaryColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Paste Bank SMS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. BDT 500.00 debited from a/c ... for bKash Payment',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isNotEmpty) {
                            final parsed = SmsParser.parseRawSmsText(text, widget.userId);
                            if (parsed != null && parsed.amount > 0) {
                              final id = parsed.id;
                              if (SmsImportTracker.isImported(id)) {
                                Fluttertoast.showToast(
                                  msg: 'This transaction was already imported previously!',
                                );
                                return;
                              }
                              final isAlreadyInSheet = _parsedExpenses.any((e) => e.id == id);
                              if (isAlreadyInSheet) {
                                Fluttertoast.showToast(
                                  msg: 'This SMS message is already in the list!',
                                );
                                return;
                              }

                              setState(() {
                                final exp = Expense(
                                  id: id,
                                  userId: parsed.userId,
                                  title: parsed.title,
                                  amount: parsed.amount,
                                  date: parsed.date,
                                  type: parsed.type,
                                  category: parsed.category,
                                );
                                _smsBodies[id] = text;
                                _parsedExpenses.insert(0, exp);
                                _selectedExpenses.add(exp);
                              });
                              Navigator.pop(ctx);
                              Fluttertoast.showToast(msg: 'SMS Parsed! Review and import.');
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'Could not detect amount. Please check SMS text.');
                            }
                          }
                        },
                        child: const Text(
                          'Parse & Add',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAmountDialog(Expense exp) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = TextEditingController(
      text: (_manualAmounts[exp.id] ?? (exp.amount > 0 ? exp.amount : ''))
          .toString(),
    );

    final glassBg = isDark
        ? Colors.black.withOpacity(0.75)
        : Colors.white.withOpacity(0.85);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.08);

    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: glassBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Amount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                  ),
                ],
              ),
            ),
          ),
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
      SmsImportTracker.markAsImported(exp.id);
      count++;
    }

    Navigator.pop(context);
    if (count > 0) {
      AnimationHelper.showSuccess(context, 'Imported $count SMS Transactions!');
    } else {
      Fluttertoast.showToast(msg: 'No transactions imported.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final glassBg = isDark
        ? Colors.black.withOpacity(0.75)
        : Colors.white.withOpacity(0.85);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.08);
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardBg = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04);

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
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        if (_selectedExpenses.length == _parsedExpenses.length) {
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
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (widget.wallets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.black.withOpacity(0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 20, color: theme.primaryColor),
                    const SizedBox(width: 10),
                    Text(
                      'Import to Wallet:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedWalletId,
                          dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
                          items: widget.wallets.map((wallet) {
                            return DropdownMenuItem<String>(
                              value: wallet.id,
                              child: Text(
                                wallet.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedWalletId = val),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _parsedExpenses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mark_email_read_rounded,
                              size: 52,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Quick SMS Expense Conversion',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Copy your bank transaction SMS and paste it below to extract expenses automatically.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : Colors.black54,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => _showPasteSmsDialog(context),
                            icon: const Icon(Icons.paste_rounded, size: 18),
                            label: const Text(
                              'Paste Bank SMS Text',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _parsedExpenses.length,
                    itemBuilder: (context, index) {
                      final exp = _parsedExpenses[index];
                      final isSelected = _selectedExpenses.contains(exp);
                      final amount = _manualAmounts[exp.id] ?? exp.amount;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? theme.primaryColor
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          leading: Checkbox(
                            value: isSelected,
                            activeColor: theme.primaryColor,
                            onChanged: (_) => _toggleSelect(exp),
                          ),
                          title: Text(
                            exp.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${exp.category} • ${_formatDate(exp.date)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _smsBodies[exp.id] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.3,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          trailing: GestureDetector(
                            onTap: () => _showAmountDialog(exp),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: amount > 0
                                    ? Colors.redAccent.withOpacity(0.1)
                                    : theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
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
                                          : theme.primaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.edit_rounded,
                                    size: 13,
                                    color: amount > 0 ? Colors.redAccent : theme.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_parsedExpenses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: theme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => _showPasteSmsDialog(context),
                      icon: Icon(Icons.paste_rounded, color: theme.primaryColor, size: 18),
                      label: Text(
                        'Paste Another Bank SMS',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _importSelected,
                      child: Text(
                        'Import Selected (${_selectedExpenses.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
