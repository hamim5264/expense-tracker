import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:expense_tracker/core/common/utils/report_storage_service.dart';
import 'package:expense_tracker/core/common/utils/pdf_report_service.dart';
import 'package:expense_tracker/core/common/utils/transaction_totals.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/pages/pdf_viewer_page.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/reports_header_widget.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/reports_filter_bar.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/report_card_widget.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/reports_empty_widget.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/generate_report_sheet.dart';

class ExpenseReportsPage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const ExpenseReportsPage());

  const ExpenseReportsPage({super.key});

  @override
  State<ExpenseReportsPage> createState() => _ExpenseReportsPageState();
}

class _ExpenseReportsPageState extends State<ExpenseReportsPage> {
  List<SavedReport> _reports = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    setState(() {
      _reports = ReportStorageService.getSavedReports();
    });
  }

  List<SavedReport> get _filteredReports {
    if (_selectedFilter == 'All') return _reports;

    final filterKey = _selectedFilter.toLowerCase();
    return _reports.where((r) {
      final period = r.period.toLowerCase();
      final fileName = r.fileName.toLowerCase();
      return period.contains(filterKey) || fileName.contains(filterKey);
    }).toList();
  }

  void _openPdf(SavedReport report) {
    Navigator.push(context, PdfViewerPage.route(report));
  }

  Future<void> _downloadAndOpenPdf(SavedReport report) async {
    var path = report.filePath;
    var file = File(path);
    if (!await file.exists()) {
      path = report.downloadsPath;
      file = File(path);
    }
    if (!await file.exists()) {
      Fluttertoast.showToast(msg: 'File not found on device.');
      return;
    }
    Fluttertoast.showToast(msg: 'Opening in external viewer...');
    await OpenFilex.open(path);
  }

  Future<void> _deleteReport(SavedReport report) async {
    await ReportStorageService.deleteReport(report.id);
    _loadReports();
    Fluttertoast.showToast(msg: 'Report deleted.');
  }

  Future<void> _confirmDeleteAll() async {
    if (_reports.isEmpty) {
      Fluttertoast.showToast(msg: 'No reports to delete.');
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1A2C) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Delete all reports?',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF211B38),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'This will permanently remove all generated reports from your device storage. This action cannot be undone.',
            style: TextStyle(
              color: isDark ? const Color(0xFFA69EB8) : const Color(0xFF817A9B),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text(
                'Delete All',
                style: TextStyle(
                  color: Color(0xFFFF5263),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ReportStorageService.clearAll();
      _loadReports();
      Fluttertoast.showToast(msg: 'All reports cleared.');
    }
  }

  void _openGenerateReportSheet() {
    GenerateReportSheet.show(
      context,
      onSelectReportType: (type, dateRange) {
        _handleGenerateReport(type, dateRange);
      },
    );
  }

  Future<void> _handleGenerateReport(
    String type, [
    DateTimeRange? dateRange,
  ]) async {
    final expenseState = context.read<ExpenseBloc>().state;
    if (expenseState is! ExpenseSuccess || expenseState.expenses.isEmpty) {
      Fluttertoast.showToast(msg: 'No transactions found to generate report.');
      return;
    }

    List<Expense> targetTransactions = [];
    String periodLabel = '';
    String reportType = '';
    double totalAmount = 0;

    if (type == 'expense') {
      targetTransactions = expenseState.expenses
          .where((tx) =>
              tx.type.toLowerCase() == 'expense' &&
              !TransactionTotals.isInternalTransfer(tx))
          .toList();
      periodLabel = 'Expense Report';
      reportType = 'expense';
      totalAmount = TransactionTotals.expenses(targetTransactions);
    } else if (type == 'income') {
      targetTransactions = expenseState.expenses
          .where((tx) =>
              tx.type.toLowerCase() == 'income' &&
              !TransactionTotals.isInternalTransfer(tx))
          .toList();
      periodLabel = 'Income Report';
      reportType = 'income';
      totalAmount = TransactionTotals.income(targetTransactions);
    } else if (type == 'custom' && dateRange != null) {
      targetTransactions = expenseState.expenses.where((tx) {
        if (TransactionTotals.isInternalTransfer(tx)) return false;
        return tx.date.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
            tx.date.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
      final startStr = '${dateRange.start.day}/${dateRange.start.month}';
      final endStr = '${dateRange.end.day}/${dateRange.end.month}';
      periodLabel = '$startStr - $endStr Custom';
      reportType = 'all';
      totalAmount = TransactionTotals.income(targetTransactions) -
          TransactionTotals.expenses(targetTransactions);
    } else {
      // All Transactions
      targetTransactions =
          TransactionTotals.externalTransactions(expenseState.expenses);
      periodLabel = 'All Transactions';
      reportType = 'all';
      totalAmount = TransactionTotals.income(targetTransactions) -
          TransactionTotals.expenses(targetTransactions);
    }

    if (targetTransactions.isEmpty) {
      Fluttertoast.showToast(
        msg: 'No transactions available for the selected type.',
      );
      return;
    }

    String userName = 'User';
    String currency = 'USD';
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      userName = authState.user.username?.isNotEmpty == true
          ? authState.user.username!
          : authState.user.name;
      currency = authState.user.currency;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF563294)),
      ),
    );

    await PdfReportService.generateAndSaveReport(
      transactions: targetTransactions,
      userName: userName,
      currency: currency,
      period: periodLabel,
      type: reportType,
      totalAmount: totalAmount,
      onSuccess: (_) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // dismiss loading
          _loadReports();
          Fluttertoast.showToast(msg: 'Report generated successfully!');
        }
      },
      onFailed: (err) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // dismiss loading
          Fluttertoast.showToast(msg: 'Failed to generate report: $err');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF13111C) : const Color(0xFFFAF8FE);
    final filtered = _filteredReports;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            // Top Purple Gradient Header (extends fully behind status bar)
            ReportsHeaderWidget(
              reportsCount: _reports.length,
              onBack: () => Navigator.pop(context),
              onDeleteAll: _confirmDeleteAll,
            ),

            // Content Area with Filters, List & Floating Generate Button
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Filter Chips Bar (All, Expense, Income, Custom)
                      ReportsFilterBar(
                        selectedFilter: _selectedFilter,
                        onFilterSelected: (val) {
                          setState(() {
                            _selectedFilter = val;
                          });
                        },
                      ),

                      // Reports List or Empty State
                      Expanded(
                        child: filtered.isEmpty
                            ? ReportsEmptyWidget(
                                currentFilter: _selectedFilter,
                                onGenerate: _openGenerateReportSheet,
                              )
                            : ListView.builder(
                                padding: EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  110 + bottomInset,
                                ),
                                physics: const BouncingScrollPhysics(),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final report = filtered[index];
                                  return ReportCardWidget(
                                    report: report,
                                    onPreview: () => _openPdf(report),
                                    onDownload: () =>
                                        _downloadAndOpenPdf(report),
                                    onDelete: () => _deleteReport(report),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),

                  // Floating "+ Generate Report" Pill Button (positioned above native navigation bar)
                  Positioned(
                    right: 20,
                    bottom: 24 + bottomInset,
                    child: _buildGenerateButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openGenerateReportSheet,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF8547CA),
                Color(0xFF542B91),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF563294).withOpacity(0.32),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.plus,
                color: Colors.white,
                size: 22,
              ),
              SizedBox(width: 9),
              Text(
                'Generate Report',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
