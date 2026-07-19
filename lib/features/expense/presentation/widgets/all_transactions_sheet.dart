import 'dart:ui';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/transaction_item_tile.dart';
import 'package:flutter/material.dart';

class AllTransactionsSheet extends StatefulWidget {
  final List<Expense> transactions;
  final String currencyCode;

  const AllTransactionsSheet({
    super.key,
    required this.transactions,
    required this.currencyCode,
  });

  @override
  State<AllTransactionsSheet> createState() => _AllTransactionsSheetState();
}

class _AllTransactionsSheetState extends State<AllTransactionsSheet> {
  int? _selectedMonth;
  int? _selectedDay;

  final List<String> _months = [
    'All Months',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final glassBg = isDark
        ? Colors.black.withOpacity(0.8)
        : Colors.white.withOpacity(0.9);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.08);
    final textColor = isDark ? Colors.white : Colors.black87;

    final filteredTransactions = widget.transactions.where((tx) {
      if (_selectedMonth != null && tx.date.month != _selectedMonth) {
        return false;
      }
      if (_selectedDay != null && tx.date.day != _selectedDay) {
        return false;
      }
      return true;
    }).toList();

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
                    'All Transactions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '${filteredTransactions.length} found',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: _selectedMonth,
                          dropdownColor: isDark
                              ? const Color(0xFF1E1B29)
                              : Colors.white,
                          icon: const Icon(Icons.arrow_drop_down, size: 20),
                          hint: Text(
                            'Month',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          isExpanded: true,
                          items: List.generate(_months.length, (idx) {
                            return DropdownMenuItem<int?>(
                              value: idx == 0 ? null : idx,
                              child: Text(
                                _months[idx],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            );
                          }),
                          onChanged: (val) {
                            setState(() {
                              _selectedMonth = val;
                              _selectedDay = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: _selectedDay,
                          dropdownColor: isDark
                              ? const Color(0xFF1E1B29)
                              : Colors.white,
                          icon: const Icon(Icons.arrow_drop_down, size: 20),
                          hint: Text(
                            'Day',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          isExpanded: true,
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text(
                                'All Days',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            ...List.generate(31, (idx) {
                              final dayNum = idx + 1;
                              return DropdownMenuItem<int?>(
                                value: dayNum,
                                child: Text(
                                  'Day $dayNum',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedDay = val;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: filteredTransactions.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions match filters.',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black45,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = filteredTransactions[index];
                        return TransactionItemTile(
                          transaction: tx,
                          currencyCode: widget.currencyCode,
                          isDark: isDark,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
