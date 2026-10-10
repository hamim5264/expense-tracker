import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';

class EmiCalculatorSheet extends StatefulWidget {
  final String currency;
  final void Function(double principal, double rate, int months)? onApplyToLoan;

  const EmiCalculatorSheet({
    super.key,
    this.currency = 'USD',
    this.onApplyToLoan,
  });

  @override
  State<EmiCalculatorSheet> createState() => _EmiCalculatorSheetState();
}

class _EmiCalculatorSheetState extends State<EmiCalculatorSheet> {
  double _principal = 10000;
  double _annualRate = 9.5;
  int _tenureMonths = 24;

  double get _monthlyEmi {
    if (_principal <= 0) return 0;
    if (_annualRate <= 0) {
      return _tenureMonths > 0 ? _principal / _tenureMonths : _principal;
    }
    final r = (_annualRate / 12) / 100;
    final n = _tenureMonths;
    final factor = pow(1 + r, n).toDouble();
    return (_principal * r * factor) / (factor - 1);
  }

  double get _totalPayable => _monthlyEmi * _tenureMonths;
  double get _totalInterest => _totalPayable - _principal;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1B28) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: bottomInset + (bottomSafeArea > 0 ? bottomSafeArea + 16 : 28),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    CupertinoIcons.circle_grid_hex_fill,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EMI & Loan Simulator',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Accurate reducing-balance calculation',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(CupertinoIcons.xmark_circle_fill),
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Result Highlight Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [primaryColor.withValues(alpha: 0.25), const Color(0xFF26263A)]
                      : [primaryColor.withValues(alpha: 0.12), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'ESTIMATED MONTHLY INSTALLMENT',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CurrencyService.format(_monthlyEmi, widget.currency),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Total Interest',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                CurrencyService.format(_totalInterest, widget.currency),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 28,
                        width: 1,
                        color: isDark ? Colors.white12 : Colors.grey[300],
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Total Repayable',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                CurrencyService.format(_totalPayable, widget.currency),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // Loan Principal Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Loan Amount',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${CurrencyService.getSymbol(widget.currency)} ${_principal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            Slider(
              value: _principal.clamp(100, 200000),
              min: 100,
              max: 200000,
              divisions: 200,
              activeColor: primaryColor,
              onChanged: (val) => setState(() => _principal = val),
            ),
            const SizedBox(height: 12),
            // Interest Rate Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Annual Interest Rate',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_annualRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            Slider(
              value: _annualRate.clamp(0, 30),
              min: 0,
              max: 30,
              divisions: 60,
              activeColor: primaryColor,
              onChanged: (val) => setState(() => _annualRate = val),
            ),
            const SizedBox(height: 12),
            // Tenure Months Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tenure (Months)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  '$_tenureMonths months (${(_tenureMonths / 12).toStringAsFixed(1)} yrs)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            Slider(
              value: _tenureMonths.toDouble().clamp(1, 120),
              min: 1,
              max: 120,
              divisions: 119,
              activeColor: primaryColor,
              onChanged: (val) => setState(() => _tenureMonths = val.round()),
            ),
            const SizedBox(height: 24),
            if (widget.onApplyToLoan != null)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onApplyToLoan!(_principal, _annualRate, _tenureMonths);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(CupertinoIcons.arrow_right_circle_fill, size: 20),
                  label: const Text(
                    'Use Terms in New Loan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
