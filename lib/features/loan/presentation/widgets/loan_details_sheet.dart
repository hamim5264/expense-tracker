import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';

import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_repayment.dart';
import '../../data/services/loan_storage_service.dart';
import 'log_repayment_sheet.dart';

class LoanDetailsSheet extends StatefulWidget {
  final Loan loan;
  final String currency;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onUpdated;

  const LoanDetailsSheet({
    super.key,
    required this.loan,
    required this.currency,
    required this.isDark,
    required this.primaryColor,
    required this.onUpdated,
  });

  @override
  State<LoanDetailsSheet> createState() => _LoanDetailsSheetState();
}

class _LoanDetailsSheetState extends State<LoanDetailsSheet> {
  late Loan _currentLoan;

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  void initState() {
    super.initState();
    _currentLoan = widget.loan;
  }

  Future<void> _reloadLoan() async {
    final list = await LoanStorageService.loadLocalCache(_currentLoan.userId);
    final updated = list.where((l) => l.id == _currentLoan.id).toList();
    if (updated.isNotEmpty && mounted) {
      setState(() {
        _currentLoan = updated.first;
      });
      widget.onUpdated();
    }
  }

  Future<void> _deleteRepayment(LoanRepayment repayment) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Repayment'),
        content: Text(
          'Remove payment of ${CurrencyService.format(repayment.amount, widget.currency)} made on ${_formatDate(repayment.paymentDate)}?',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await LoanStorageService.deleteRepayment(_currentLoan.userId, _currentLoan.id, repayment.id);
      await _reloadLoan();
    }
  }

  Future<void> _deleteLoan() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Loan'),
        content: Text(
          'Are you sure you want to delete the loan with ${_currentLoan.counterparty}? This will also delete all associated payment records.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Loan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await LoanStorageService.deleteLoan(_currentLoan.userId, _currentLoan.id);
      widget.onUpdated();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loan deleted successfully')),
        );
      }
    }
  }

  void _openLogRepayment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LogRepaymentSheet(
        loan: _currentLoan,
        currency: widget.currency,
        isDark: widget.isDark,
        primaryColor: widget.primaryColor,
        onSaved: () {
          _reloadLoan();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final primaryColor = widget.primaryColor;
    final isBorrowed = _currentLoan.isBorrowed;
    final isSettled = _currentLoan.isSettled;
    final remaining = _currentLoan.remainingBalance;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B1B28) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isBorrowed
                            ? Colors.redAccent.withValues(alpha: 0.12)
                            : Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isBorrowed
                            ? CupertinoIcons.arrow_up_circle_fill
                            : CupertinoIcons.arrow_down_circle_fill,
                        color: isBorrowed ? Colors.redAccent : Colors.green,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentLoan.counterparty,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isBorrowed ? 'Liability (Money Owed)' : 'Receivable (Money Lent)',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete Loan',
                      onPressed: _deleteLoan,
                      icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent, size: 20),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Main overview card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [const Color(0xFF26263A), const Color(0xFF1E1E2E)]
                              : [const Color(0xFFF7F8FA), const Color(0xFFEDEDF2)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSettled
                                        ? 'Fully Settled'
                                        : (isBorrowed ? 'Outstanding Debt' : 'Pending Receipt'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyService.format(remaining, widget.currency),
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: isSettled
                                          ? Colors.green
                                          : (isBorrowed ? Colors.redAccent : primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSettled
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : (isBorrowed
                                          ? Colors.redAccent.withValues(alpha: 0.15)
                                          : Colors.blue.withValues(alpha: 0.15)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSettled
                                          ? CupertinoIcons.checkmark_seal_fill
                                          : CupertinoIcons.clock_fill,
                                      size: 14,
                                      color: isSettled
                                          ? Colors.green
                                          : (isBorrowed ? Colors.redAccent : Colors.blue),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      isSettled
                                          ? 'Settled'
                                          : (_currentLoan.isOverdue ? 'Overdue' : 'Active'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSettled
                                            ? Colors.green
                                            : (isBorrowed ? Colors.redAccent : Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _currentLoan.progress,
                              minHeight: 8,
                              backgroundColor: isDark ? Colors.white12 : Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isSettled ? Colors.green : primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Paid: ${widget.currency}${_currentLoan.totalPaid.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${(_currentLoan.progress * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Financial breakdown matrix
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF232336) : const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: CupertinoIcons.money_dollar_circle,
                            label: 'Principal Amount',
                            value: CurrencyService.format(_currentLoan.principal, widget.currency),
                            isDark: isDark,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: CupertinoIcons.percent,
                            label: 'Interest / Profit',
                            value: _currentLoan.interestType == 'none'
                                ? '0% (Interest-Free)'
                                : _currentLoan.interestType == 'percentage'
                                    ? '${_currentLoan.interestRate.toStringAsFixed(1)}% p.a. (+${CurrencyService.format(_currentLoan.totalInterest, widget.currency)})'
                                    : '+${CurrencyService.format(_currentLoan.totalInterest, widget.currency)} (Flat)',
                            isDark: isDark,
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: CupertinoIcons.chart_bar_alt_fill,
                            label: 'Total Payable',
                            value: CurrencyService.format(_currentLoan.totalPayable, widget.currency),
                            isDark: isDark,
                            boldValue: true,
                          ),
                          if (_currentLoan.monthlyEmi > 0) ...[
                            const Divider(height: 20),
                            _buildDetailRow(
                              icon: CupertinoIcons.timer,
                              label: 'Monthly EMI',
                              value: '${CurrencyService.format(_currentLoan.monthlyEmi, widget.currency)} / month',
                              isDark: isDark,
                              colorValue: primaryColor,
                            ),
                          ],
                          const Divider(height: 20),
                          _buildDetailRow(
                            icon: CupertinoIcons.calendar,
                            label: 'Start Date',
                            value: _formatDate(_currentLoan.startDate),
                            isDark: isDark,
                          ),
                          if (_currentLoan.dueDate != null) ...[
                            const Divider(height: 20),
                            _buildDetailRow(
                              icon: CupertinoIcons.flag,
                              label: 'Target Due Date',
                              value: _formatDate(_currentLoan.dueDate!),
                              isDark: isDark,
                              colorValue: _currentLoan.isOverdue && !isSettled ? Colors.redAccent : null,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_currentLoan.notes != null && _currentLoan.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF232336) : const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(CupertinoIcons.doc_plaintext, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _currentLoan.notes!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Repayment log header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment History (${_currentLoan.repayments.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isSettled)
                          TextButton.icon(
                            onPressed: _openLogRepayment,
                            icon: const Icon(CupertinoIcons.plus_circle, size: 16),
                            label: const Text('Add Payment'),
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_currentLoan.repayments.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(
                              CupertinoIcons.tray,
                              size: 40,
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No payments recorded yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(_currentLoan.repayments.length, (index) {
                        final sortedList = List<LoanRepayment>.from(_currentLoan.repayments)
                          ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
                        final item = sortedList[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF232336) : const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  CupertinoIcons.check_mark,
                                  color: Colors.green,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDate(item.paymentDate),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (item.notes != null && item.notes!.isNotEmpty)
                                      Text(
                                        item.notes!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                '+${CurrencyService.format(item.amount, widget.currency)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _deleteRepayment(item),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    CupertinoIcons.trash,
                                    size: 16,
                                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              if (!isSettled)
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom + 12
                        : 20,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _openLogRepayment,
                      icon: const Icon(CupertinoIcons.plus_circle_fill, size: 20),
                      label: Text(
                        isBorrowed ? 'Record Payment Made' : 'Record Payment Received',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    bool boldValue = false,
    Color? colorValue,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: boldValue ? FontWeight.bold : FontWeight.w600,
            color: colorValue,
          ),
        ),
      ],
    );
  }
}
