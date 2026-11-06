import 'package:expense_tracker/core/common/utils/animation_helper.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/core/common/utils/pdf_report_service.dart';
import 'package:expense_tracker/core/common/utils/transaction_totals.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/transaction_item_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AllTransactionsPage extends StatefulWidget {
  final List<Expense> transactions;
  final String currencyCode;
  final String userName;

  const AllTransactionsPage({
    super.key,
    required this.transactions,
    required this.currencyCode,
    required this.userName,
  });

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  int? _year;
  int? _month;

  List<Expense> get _filtered => widget.transactions.where((tx) {
    return (_year == null || tx.date.year == _year) &&
        (_month == null || tx.date.month == _month);
  }).toList()..sort((a, b) => b.date.compareTo(a.date));

  String get _period {
    if (_year == null) return 'All Transactions';
    if (_month == null) return '$_year';
    return '${_month!.toString().padLeft(2, '0')}-$_year';
  }

  Future<void> _export(List<Expense> transactions) async {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions in this period.')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    await PdfReportService.generateAndSaveReport(
      transactions: transactions,
      userName: widget.userName,
      currency: widget.currencyCode,
      period: _period,
      type: 'all',
      totalAmount: TransactionTotals.income(transactions) -
          TransactionTotals.expenses(transactions),
      onSuccess: (_) {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        AnimationHelper.showSuccess(context, 'PDF saved in App Reports.');
      },
      onFailed: (error) {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        AnimationHelper.showFailed(context, 'PDF export failed: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final years = widget.transactions.map((tx) => tx.date.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    final transactions = _filtered;
    final income = TransactionTotals.income(transactions);
    final expenses = TransactionTotals.expenses(transactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        actions: [
          IconButton(
            tooltip: 'Export selected period',
            onPressed: () => _export(transactions),
            icon: const Icon(CupertinoIcons.doc_text),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    value: _year,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All years')),
                      ...years.map((year) => DropdownMenuItem(
                        value: year,
                        child: Text('$year'),
                      )),
                    ],
                    onChanged: (value) => setState(() {
                      _year = value;
                      if (value == null) _month = null;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    value: _month,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All months')),
                      ...List.generate(12, (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text(_months[index]),
                      )),
                    ],
                    onChanged: (value) => setState(() => _month = value),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 2, 16, 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF231C38),
                        Color(0xFF171324),
                      ]
                    : const [
                        Color(0xFFFFFFFF),
                        Color(0xFFF7F3FD),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF6B4EE6).withOpacity(0.28)
                    : const Color(0xFF7E57C2).withOpacity(0.20),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.35)
                      : const Color(0xFF563294).withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _CalculationItem(
                    label: 'Income',
                    amount: income,
                    currencyCode: widget.currencyCode,
                    icon: CupertinoIcons.arrow_down_left,
                    accentColor: const Color(0xFF10B981),
                    badgeBgColor: const Color(0xFF10B981)
                        .withOpacity(isDark ? 0.18 : 0.12),
                    isDark: isDark,
                    prefix: '+',
                  ),
                ),
                Container(
                  height: 38,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06),
                ),
                Expanded(
                  child: _CalculationItem(
                    label: 'Expenses',
                    amount: expenses,
                    currencyCode: widget.currencyCode,
                    icon: CupertinoIcons.arrow_up_right,
                    accentColor: const Color(0xFFEF4444),
                    badgeBgColor: const Color(0xFFEF4444)
                        .withOpacity(isDark ? 0.18 : 0.12),
                    isDark: isDark,
                    prefix: '-',
                  ),
                ),
                Container(
                  height: 38,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06),
                ),
                Expanded(
                  child: _CalculationItem(
                    label: 'Net Flow',
                    amount: (income - expenses).abs(),
                    currencyCode: widget.currencyCode,
                    icon: (income >= expenses)
                        ? CupertinoIcons.sparkles
                        : CupertinoIcons.equal_circle_fill,
                    accentColor: (income >= expenses)
                        ? (isDark
                            ? const Color(0xFF818CF8)
                            : const Color(0xFF5B4DDF))
                        : const Color(0xFFEF4444),
                    badgeBgColor: ((income >= expenses)
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFEF4444))
                        .withOpacity(isDark ? 0.18 : 0.12),
                    isDark: isDark,
                    prefix: (income >= expenses) ? '+' : '-',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${transactions.length} transactions',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('No transactions for this period.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) => TransactionItemTile(
                      transaction: transactions[index],
                      currencyCode: widget.currencyCode,
                      isDark: isDark,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CalculationItem extends StatelessWidget {
  final String label;
  final double amount;
  final String currencyCode;
  final IconData icon;
  final Color accentColor;
  final Color badgeBgColor;
  final bool isDark;
  final String prefix;

  const _CalculationItem({
    required this.label,
    required this.amount,
    required this.currencyCode,
    required this.icon,
    required this.accentColor,
    required this.badgeBgColor,
    required this.isDark,
    required this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = CurrencyService.format(amount, currencyCode);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 11,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFA69EB8)
                      : const Color(0xFF7A728E),
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$prefix$formatted',
            maxLines: 1,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: accentColor,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}
