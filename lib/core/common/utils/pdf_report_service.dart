import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class PdfReportService {
  static Future<void> generateAndSaveReport({
    required List<Expense> transactions,
    required String userName,
    required String currency,
    required String period,
    required String type,
    required double totalAmount,
    void Function(String filePath)? onSuccess,
    void Function(String error)? onFailed,
  }) async {
    final pdf = pw.Document();

    pw.Font? notoRegular;
    pw.Font? notoBold;
    try {
      final regularBytes = await rootBundle.load(
        'assets/fonts/NotoSans-Regular.ttf',
      );
      final boldBytes = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      notoRegular = pw.Font.ttf(regularBytes);
      notoBold = pw.Font.ttf(boldBytes);
    } catch (_) {}

    pw.TextStyle baseStyle(double size, {bool bold = false, PdfColor? color}) {
      return pw.TextStyle(
        font: bold ? (notoBold ?? notoRegular) : notoRegular,
        fontSize: size,
        color: color,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      );
    }

    final primaryColor = PdfColor.fromHex('#4F378A');
    final accentColor = PdfColor.fromHex('#311B92');
    final lightBgColor = PdfColor.fromHex('#F9F9FB');
    final darkTextColor = PdfColor.fromHex('#1E1E1E');
    final greyTextColor = PdfColor.fromHex('#666666');

    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load(
        'assets/images/logos/app_final_splash_logo.png',
      );
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {}

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 45,
                        height: 45,
                        margin: const pw.EdgeInsets.only(right: 12),
                        child: pw.Image(logoImage),
                      )
                    else
                      pw.Container(
                        width: 45,
                        height: 45,
                        margin: const pw.EdgeInsets.only(right: 12),
                        decoration: pw.BoxDecoration(
                          color: primaryColor,
                          shape: pw.BoxShape.circle,
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'E',
                          style: baseStyle(
                            22,
                            bold: true,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Onyx',
                          style: baseStyle(20, bold: true, color: primaryColor),
                        ),
                        pw.Text(
                          'Smart Financial Analytics',
                          style: baseStyle(10, color: greyTextColor),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'FINANCIAL STATEMENT',
                      style: baseStyle(14, bold: true, color: accentColor),
                    ),
                    pw.Text(
                      'Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: baseStyle(10, color: greyTextColor),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(color: primaryColor, thickness: 1.5),
            pw.SizedBox(height: 20),

            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: lightBgColor,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'REPORT FOR:',
                        style: baseStyle(8, bold: true, color: greyTextColor),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        userName,
                        style: baseStyle(14, bold: true, color: darkTextColor),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'TIMEFRAME / TYPE:',
                        style: baseStyle(8, bold: true, color: greyTextColor),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '${period.toUpperCase()} - ${type.toUpperCase()}',
                        style: baseStyle(12, bold: true, color: darkTextColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TOTAL ${type == 'expense' ? 'SPENDINGS' : 'EARNINGS'}',
                          style: baseStyle(10, color: PdfColors.white),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          '$currency ${totalAmount.toStringAsFixed(2)}',
                          style: baseStyle(
                            24,
                            bold: true,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            pw.Text(
              'Detailed Transaction Ledger',
              style: baseStyle(14, bold: true, color: darkTextColor),
            ),
            pw.SizedBox(height: 12),

            pw.Table(
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(
                  color: PdfColors.grey200,
                  width: 0.8,
                ),
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'TITLE / MERCHANT',
                        style: baseStyle(9, bold: true, color: darkTextColor),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'CATEGORY',
                        style: baseStyle(9, bold: true, color: darkTextColor),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'DATE',
                        style: baseStyle(9, bold: true, color: darkTextColor),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'AMOUNT',
                          style: baseStyle(9, bold: true, color: darkTextColor),
                        ),
                      ),
                    ),
                  ],
                ),
                ...transactions.map((tx) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: pw.Text(tx.title, style: baseStyle(10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: pw.Text(tx.category, style: baseStyle(10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: pw.Text(
                          '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                          style: baseStyle(10),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                            '$currency ${tx.amount.toStringAsFixed(2)}',
                            style: baseStyle(
                              10,
                              bold: true,
                              color: tx.type == 'income'
                                  ? PdfColors.green
                                  : PdfColors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 32),
            pw.Divider(color: primaryColor, thickness: 1.5),
            pw.SizedBox(height: 16),
            pw.Text(
              'Financial Summary',
              style: baseStyle(13, bold: true, color: primaryColor),
            ),
            pw.SizedBox(height: 12),

            () {
              final double totalIncome = transactions
                  .where((tx) => tx.type == 'income')
                  .fold(0.0, (s, tx) => s + tx.amount);
              final double totalExpenses = transactions
                  .where((tx) => tx.type == 'expense')
                  .fold(0.0, (s, tx) => s + tx.amount);
              final double netBalance = totalIncome - totalExpenses;
              final int txCount = transactions.length;

              pw.Widget summaryRow(
                String label,
                String value, {
                PdfColor? valueColor,
                bool isTotal = false,
              }) {
                return pw.Container(
                  margin: const pw.EdgeInsets.symmetric(vertical: 4),
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: pw.BoxDecoration(
                    color: isTotal ? primaryColor : lightBgColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        label,
                        style: baseStyle(
                          isTotal ? 11 : 10,
                          bold: true,
                          color: isTotal ? PdfColors.white : darkTextColor,
                        ),
                      ),
                      pw.Text(
                        value,
                        style: baseStyle(
                          isTotal ? 13 : 11,
                          bold: true,
                          color: isTotal
                              ? PdfColors.white
                              : (valueColor ?? darkTextColor),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  summaryRow(
                    'Total Income',
                    '$currency ${totalIncome.toStringAsFixed(2)}',
                    valueColor: PdfColors.green,
                  ),
                  summaryRow(
                    'Total Expenses',
                    '$currency ${totalExpenses.toStringAsFixed(2)}',
                    valueColor: PdfColors.red,
                  ),
                  summaryRow(
                    'Total Transactions',
                    '$txCount',
                    valueColor: darkTextColor,
                  ),
                  summaryRow(
                    'Net Balance (Remaining)',
                    '$currency ${netBalance.toStringAsFixed(2)}',
                    valueColor: netBalance >= 0
                        ? PdfColors.green
                        : PdfColors.red,
                    isTotal: true,
                  ),
                ],
              );
            }(),

            pw.SizedBox(height: 20),
            pw.Divider(color: primaryColor, thickness: 0.5),
            pw.SizedBox(height: 8),
            pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Text(
                'Generated by Onyx • Smart Financial Analytics',
                style: baseStyle(8, color: greyTextColor),
              ),
            ),
          ];
        },
      ),
    );

    try {
      String? selectedPath;
      try {
        selectedPath = await FilePicker.platform.getDirectoryPath();
      } catch (e) {
        debugPrint('FilePicker error: $e');
      }

      final String folderPath =
          selectedPath ?? (await getApplicationDocumentsDirectory()).path;
      final filePath =
          "$folderPath/onyx_Report_${period}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (onSuccess != null) {
        onSuccess(filePath);
      } else {
        Fluttertoast.showToast(
          msg: "PDF saved successfully!\n$filePath",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      if (onFailed != null) {
        onFailed('$e');
      } else {
        Fluttertoast.showToast(msg: "Error saving PDF: $e");
      }
    }
  }
}
