import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:expense_tracker/core/common/utils/theme_service.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';

class ClearTransactionHistorySheet extends StatefulWidget {
  final String userId;

  const ClearTransactionHistorySheet({super.key, required this.userId});

  @override
  State<ClearTransactionHistorySheet> createState() =>
      _ClearTransactionHistorySheetState();
}

class _ClearTransactionHistorySheetState
    extends State<ClearTransactionHistorySheet> {
  // 'all', 'expense', 'income'
  String _selectedType = 'expense';

  // 'all_time', 'range', 'specific', 'monthly'
  String _selectedFilterMode = 'all_time';

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  DateTime _specificDate = DateTime.now();

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  bool _isProcessing = false;

  final List<String> _months = [
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

  Future<void> _pickDateRange(BuildContext context, Color primaryColor) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: isDark ? const Color(0xFF1E1B29) : Colors.white,
            scaffoldBackgroundColor: isDark ? const Color(0xFF1E1B29) : Colors.white,
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E1B29),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _pickSpecificDate(BuildContext context, Color primaryColor) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: _specificDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: isDark ? const Color(0xFF1E1B29) : Colors.white,
            scaffoldBackgroundColor: isDark ? const Color(0xFF1E1B29) : Colors.white,
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E1B29),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _specificDate = picked;
      });
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _handleClear(Color primaryColor) {
    setState(() => _isProcessing = true);

    DateTime? rangeStart;
    DateTime? rangeEnd;

    if (_selectedFilterMode == 'range') {
      rangeStart = DateTime(_startDate.year, _startDate.month, _startDate.day, 0, 0, 0);
      rangeEnd = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
    } else if (_selectedFilterMode == 'specific') {
      rangeStart = DateTime(_specificDate.year, _specificDate.month, _specificDate.day, 0, 0, 0);
      rangeEnd = DateTime(_specificDate.year, _specificDate.month, _specificDate.day, 23, 59, 59);
    } else if (_selectedFilterMode == 'monthly') {
      rangeStart = DateTime(_selectedYear, _selectedMonth, 1, 0, 0, 0);
      final lastDay = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
      rangeEnd = DateTime(_selectedYear, _selectedMonth, lastDay, 23, 59, 59);
    }

    context.read<ExpenseBloc>().add(
          ExpenseClearTransactions(
            userId: widget.userId,
            type: _selectedType,
            dateFilterMode: _selectedFilterMode,
            startDate: rangeStart,
            endDate: rangeEnd,
          ),
        );

    Navigator.pop(context);
    showToast('Transaction history cleared successfully!');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<Color>(
      valueListenable: ThemeService.primaryColorNotifier,
      builder: (context, primaryColor, _) {
        final cardBg = isDark ? const Color(0xFF1E1B29) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.white60 : Colors.black54;
        final containerBg = isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100;

        final bottomPadding = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 28;

        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: bottomPadding,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.trash_fill,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clear Transaction History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Remove specific or all transaction logs',
                          style: TextStyle(
                            fontSize: 12,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. SELECT TRANSACTION TYPE
                Text(
                  '1. SELECT TRANSACTION TYPE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildTypeChip('expense', 'Expenses', CupertinoIcons.arrow_up_right, primaryColor),
                    const SizedBox(width: 8),
                    _buildTypeChip('income', 'Incomes', CupertinoIcons.arrow_down_left, primaryColor),
                    const SizedBox(width: 8),
                    _buildTypeChip('all', 'All Both', CupertinoIcons.arrow_2_circlepath, primaryColor),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. SELECT TIME RANGE
                Text(
                  '2. SELECT TIME RANGE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterModeChip('all_time', 'All Time', CupertinoIcons.infinite, primaryColor),
                    _buildFilterModeChip('range', 'Date Range', CupertinoIcons.calendar_today, primaryColor),
                    _buildFilterModeChip('specific', 'Specific Date', CupertinoIcons.calendar, primaryColor),
                    _buildFilterModeChip('monthly', 'Monthly', CupertinoIcons.calendar_badge_minus, primaryColor),
                  ],
                ),
                const SizedBox(height: 16),

                // TIME RANGE INPUT DETAILS
                if (_selectedFilterMode == 'range') ...[
                  GestureDetector(
                    onTap: () => _pickDateRange(context, primaryColor),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: containerBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(CupertinoIcons.calendar, size: 18, color: primaryColor),
                              const SizedBox(width: 10),
                              Text(
                                '${_formatDate(_startDate)}  ➔  ${_formatDate(_endDate)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Icon(CupertinoIcons.chevron_right, size: 16, color: subTextColor),
                        ],
                      ),
                    ),
                  ),
                ] else if (_selectedFilterMode == 'specific') ...[
                  GestureDetector(
                    onTap: () => _pickSpecificDate(context, primaryColor),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: containerBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(CupertinoIcons.calendar, size: 18, color: primaryColor),
                              const SizedBox(width: 10),
                              Text(
                                _formatDate(_specificDate),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Icon(CupertinoIcons.chevron_right, size: 16, color: subTextColor),
                        ],
                      ),
                    ),
                  ),
                ] else if (_selectedFilterMode == 'monthly') ...[
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: containerBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: primaryColor.withOpacity(0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedMonth,
                              dropdownColor: cardBg,
                              items: List.generate(12, (index) {
                                return DropdownMenuItem(
                                  value: index + 1,
                                  child: Text(
                                    _months[index],
                                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                                  ),
                                );
                              }),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedMonth = val);
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
                            color: containerBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: primaryColor.withOpacity(0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedYear,
                              dropdownColor: cardBg,
                              items: List.generate(10, (index) {
                                final year = DateTime.now().year - 5 + index;
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(
                                    '$year',
                                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                                  ),
                                );
                              }),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedYear = val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Action is permanent. Selected transactions will be deleted and wallet balances updated automatically.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.red.shade900,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isProcessing ? null : () => _handleClear(primaryColor),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Clear Matching Transactions',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeChip(String id, String label, IconData icon, Color primaryColor) {
    final isSelected = _selectedType == id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterModeChip(String id, String label, IconData icon, Color primaryColor) {
    final isSelected = _selectedFilterMode == id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilterMode = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.18)
              : (isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.white60 : Colors.black54),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
