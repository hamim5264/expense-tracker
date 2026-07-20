import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/core/common/utils/show_snackbar.dart';

class ExportDataCard extends StatelessWidget {
  const ExportDataCard({super.key});

  void _exportCSV(List<Expense> expenses) {
    if (expenses.isEmpty) {
      showToast('No transaction data to export!', isError: true);
      return;
    }
    final buffer = StringBuffer();
    buffer.writeln('ID,Title,Amount,Date,Type');
    for (final e in expenses) {
      buffer.writeln(
        '"${e.id}","${e.title.replaceAll('"', '""')}",${e.amount},"${e.date.toIso8601String()}","${e.type}"',
      );
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    showToast('Expenses exported as CSV to clipboard!');
  }

  void _exportJSON(List<Expense> expenses) {
    if (expenses.isEmpty) {
      showToast('No transaction data to export!', isError: true);
      return;
    }
    final list = expenses
        .map(
          (e) => {
            'id': e.id,
            'title': e.title,
            'amount': e.amount,
            'date': e.date.toIso8601String(),
            'type': e.type,
          },
        )
        .toList();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(list);
    Clipboard.setData(ClipboardData(text: jsonStr));
    showToast('Expenses exported as JSON to clipboard!');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white60 : Colors.black54;

    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        List<Expense> expenses = [];
        if (state is ExpenseSuccess) {
          expenses = state.expenses;
        }

        return Card(
          color: isDark ? const Color(0xFF1E1B24) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? Colors.white12 : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Export your expense statements directly to the system clipboard to share or save.',
                  style: TextStyle(fontSize: 14, color: subColor),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _exportCSV(expenses),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Export CSV'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _exportJSON(expenses),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Export JSON'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
