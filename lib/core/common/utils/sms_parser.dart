import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/core/common/utils/sms_import_tracker.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class SmsParser {
  static final SmsQuery _query = SmsQuery();

  static Future<List<Expense>> scanSmsForExpenses(
    String userId, {
    List<Expense> existingExpenses = const [],
  }) async {
    try {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 250,
      );

      final List<Expense> detected = [];
      final amountRegex = RegExp(
        r'(?:bdt|tk|\$|usd|debited|charged|spent)\s*([\d,]+(?:\.\d{1,2})?)|([\d,]+(?:\.\d{1,2})?)\s*(?:bdt|tk|\$|usd|taka)',
        caseSensitive: false,
      );

      for (var msg in messages) {
        final body = msg.body ?? '';
        final lowerBody = body.toLowerCase();
        final msgDate = msg.date ?? DateTime.now();

        if (lowerBody.contains('debited') ||
            lowerBody.contains('spent') ||
            lowerBody.contains('payment') ||
            lowerBody.contains('charged') ||
            lowerBody.contains('purchase') ||
            lowerBody.contains('transaction')) {
          final match = amountRegex.firstMatch(body);
          if (match != null) {
            final amountStr = match.group(1) ?? match.group(2);
            if (amountStr != null) {
              final cleanedVal = amountStr.replaceAll(',', '');
              final amount = double.tryParse(cleanedVal) ?? 0.0;

              if (amount > 0) {
                final fingerprint = SmsImportTracker.getFingerprint(
                  smsId: msg.id,
                  sender: msg.sender,
                  date: msgDate,
                  body: body,
                  amount: amount,
                );

                if (SmsImportTracker.isImported(fingerprint)) {
                  continue;
                }

                final isAlreadyAdded = existingExpenses.any((ext) {
                  final sameAmount = (ext.amount - amount).abs() < 0.01;
                  final sameDay = ext.date.year == msgDate.year &&
                      ext.date.month == msgDate.month &&
                      ext.date.day == msgDate.day;
                  final closeTime =
                      ext.date.difference(msgDate).inMinutes.abs() < 30;
                  return sameAmount && sameDay && closeTime;
                });

                if (isAlreadyAdded) {
                  await SmsImportTracker.markAsImported(fingerprint);
                  continue;
                }

                String category = 'Others';
                if (lowerBody.contains('food') ||
                    lowerBody.contains('restaurant') ||
                    lowerBody.contains('dine')) {
                  category = 'Food';
                } else if (lowerBody.contains('shop') ||
                    lowerBody.contains('grocer')) {
                  category = 'Shopping';
                } else if (lowerBody.contains('netflix') ||
                    lowerBody.contains('uber') ||
                    lowerBody.contains('ride')) {
                  category = 'Entertainment';
                } else if (lowerBody.contains('bill') ||
                    lowerBody.contains('electric') ||
                    lowerBody.contains('internet')) {
                  category = 'Bills';
                }

                String merchant = msg.sender ?? 'SMS Alert';
                if (merchant.length > 15) merchant = merchant.substring(0, 15);

                detected.add(
                  Expense(
                    id: fingerprint,
                    userId: userId,
                    title: 'Auto: $merchant',
                    amount: amount,
                    date: msgDate,
                    type: 'expense',
                    category: category,
                  ),
                );
              }
            }
          }
        }
      }
      return detected;
    } catch (e) {
      return [];
    }
  }
}
