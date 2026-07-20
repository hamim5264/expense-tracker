import 'dart:ui';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:flutter/material.dart';

class GlassCurrencySelector extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String> onCurrencySelected;

  const GlassCurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final glassBg = isDark
        ? Colors.black.withAlpha(160)
        : Colors.white.withAlpha(200);
    final borderColor = isDark
        ? Colors.white.withAlpha(30)
        : Colors.black.withAlpha(20);
    final titleColor = isDark ? Colors.white : Colors.black87;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: glassBg,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 20),
              Text(
                'Select Currency',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: CurrencyService.supportedCurrencies.length,
                itemBuilder: (context, index) {
                  final cur = CurrencyService.supportedCurrencies[index];
                  final isSelected = cur == selectedCurrency;
                  final symbol = CurrencyService.getSymbol(cur);

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor.withAlpha(isSelected ? 30 : 0)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.primaryColor
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? theme.primaryColor
                              : (isDark
                                    ? Colors.white10
                                    : Colors.grey.shade100),
                          child: Text(
                            symbol,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          cur,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          _getCurrencyName(cur),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: theme.primaryColor,
                              )
                            : null,
                        onTap: () {
                          onCurrencySelected(cur);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'USD':
        return 'United States Dollar';
      case 'BDT':
        return 'Bangladeshi Taka';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'British Pound';
      case 'INR':
        return 'Indian Rupee';
      case 'CAD':
        return 'Canadian Dollar';
      case 'AUD':
        return 'Australian Dollar';
      default:
        return '';
    }
  }
}
