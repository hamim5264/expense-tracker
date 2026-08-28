import 'package:flutter/material.dart';

class PeriodSelectorBar extends StatelessWidget {
  final String selectedPeriod;
  final bool isDark;
  final Color primaryColor;
  final ValueChanged<String> onPeriodSelected;

  const PeriodSelectorBar({
    super.key,
    required this.selectedPeriod,
    required this.isDark,
    required this.primaryColor,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['Day', 'Week', 'Month', 'Year'].map((period) {
          final isSelected = selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPeriodSelected(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.grey.shade600),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
