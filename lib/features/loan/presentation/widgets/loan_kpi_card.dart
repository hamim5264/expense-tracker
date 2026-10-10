import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/features/loan/domain/entities/loan.dart';

class LoanKpiCard extends StatelessWidget {
  final List<Loan> loans;
  final String currency;
  final bool isDark;
  final Color primaryColor;

  const LoanKpiCard({
    super.key,
    required this.loans,
    required this.currency,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    double totalBorrowedRemaining = 0.0;
    double totalBorrowedPaid = 0.0;
    double totalLentRemaining = 0.0;
    double totalLentCollected = 0.0;

    for (var l in loans) {
      if (l.isBorrowed) {
        totalBorrowedRemaining += l.remainingBalance;
        totalBorrowedPaid += l.totalPaid;
      } else {
        totalLentRemaining += l.remainingBalance;
        totalLentCollected += l.totalPaid;
      }
    }

    final netPosition = totalLentRemaining - totalBorrowedRemaining;
    final isNetCreditor = netPosition >= 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Slim Compact Net Debt Position Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: (isNetCreditor ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(isDark ? 0.12 : 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (isNetCreditor ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isNetCreditor
                    ? CupertinoIcons.arrow_up_right_circle_fill
                    : CupertinoIcons.arrow_down_left_circle_fill,
                color: isNetCreditor ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                size: 15,
              ),
              const SizedBox(width: 7),
              Text(
                'Net Position: ',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                isNetCreditor ? 'Net Creditor' : 'Net Debtor',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isNetCreditor ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
              const Spacer(),
              Text(
                CurrencyService.format(netPosition.abs(), currency),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isNetCreditor ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 2. Separate Borrowed vs Lent Cards Side-by-Side
        Row(
          children: [
            // Borrowed Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F1824) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(isDark ? 0.35 : 0.20),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.arrow_down_circle_fill,
                          size: 13,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Borrowed',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        CurrencyService.format(totalBorrowedRemaining, currency),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Paid: ${CurrencyService.format(totalBorrowedPaid, currency)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Lent Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF182420) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(isDark ? 0.35 : 0.20),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.arrow_up_circle_fill,
                          size: 13,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Lent',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        CurrencyService.format(totalLentRemaining, currency),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Collected: ${CurrencyService.format(totalLentCollected, currency)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
