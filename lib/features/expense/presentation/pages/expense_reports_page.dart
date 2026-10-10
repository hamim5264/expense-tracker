import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_tracker/core/common/utils/report_storage_service.dart';
import 'package:expense_tracker/features/expense/presentation/pages/pdf_viewer_page.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/saved_report_item_tile.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/empty_reports_placeholder.dart';

class ExpenseReportsPage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const ExpenseReportsPage());

  const ExpenseReportsPage({super.key});

  @override
  State<ExpenseReportsPage> createState() => _ExpenseReportsPageState();
}

class _ExpenseReportsPageState extends State<ExpenseReportsPage> {
  List<SavedReport> _reports = [];

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

  void _openPdf(SavedReport report) {
    Navigator.push(context, PdfViewerPage.route(report));
  }

  Future<void> _deleteReport(SavedReport report) async {
    await ReportStorageService.deleteReport(report.id);
    _loadReports();
    Fluttertoast.showToast(msg: 'Report deleted.');
  }

  Future<void> _clearAllReports() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1B29) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Clear All Reports',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete all saved reports?',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ReportStorageService.clearAll();
      _loadReports();
      Fluttertoast.showToast(msg: 'All reports cleared.');
    }
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthNames[dt.month - 1];
    final year = dt.year;
    final hourInt = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final hour = hourInt.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';

    return '$day $month $year, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.primaryColor.computeLuminance() > 0.45;
    final headerTextColor = isLight ? const Color(0xFF1F2937) : Colors.white;
    final isDark = theme.brightness == Brightness.dark;
    final rawPrimary = theme.primaryColor;
    final isDarkPrimary = rawPrimary.computeLuminance() < 0.25;

    final effectiveAccentColor = (isDark && isDarkPrimary)
        ? Colors.purpleAccent.shade100
        : rawPrimary;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 220),
            painter: HeaderPainter(color: theme.primaryColor),
          ),
          Positioned(
            top: -20,
            left: -20,
            child: Opacity(
              opacity: 0.80,
              child: Image.asset(
                'assets/images/components/background_design.png',
                width: 250,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.back,
                          color: headerTextColor,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Expense Reports',
                            style: TextStyle(
                              color: headerTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      if (_reports.isNotEmpty)
                        IconButton(
                          tooltip: 'Clear all reports',
                          icon: Icon(
                            CupertinoIcons.trash,
                            color: headerTextColor,
                            size: 20,
                          ),
                          onPressed: _clearAllReports,
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: _reports.isEmpty
                      ? EmptyReportsPlaceholder(
                          isDark: isDark,
                          textColor: textColor,
                          primaryColor: theme.primaryColor,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _reports.length,
                          itemBuilder: (context, index) {
                            final report = _reports[index];
                            return SavedReportItemTile(
                              report: report,
                              isDark: isDark,
                              textColor: textColor,
                              effectiveAccentColor: effectiveAccentColor,
                              formattedDate: _formatDateTime(report.generatedAt),
                              onTap: () => _openPdf(report),
                              onDelete: () => _deleteReport(report),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
