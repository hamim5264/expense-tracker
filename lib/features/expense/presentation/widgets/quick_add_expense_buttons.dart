import 'package:flutter/material.dart';

class QuickAddExpenseButtons extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;

  const QuickAddExpenseButtons({
    super.key,
    required this.isDark,
    required this.onAddExpense,
    required this.onAddIncome,
  });

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          context: context,
          label: 'Expense',
          icon: Icons.north_east_rounded,
          iconColor: isDark ? const Color(0xFFEF9A9A) : const Color(0xFFE53935),
          onTap: onAddExpense,
          isDark: isDark,
        ),
        const SizedBox(width: 44),
        _buildActionButton(
          context: context,
          label: 'Income',
          icon: Icons.south_west_rounded,
          iconColor: isDark ? const Color(0xFFA5D6A7) : const Color(0xFF43A047),
          onTap: onAddIncome,
          isDark: isDark,
        ),
      ],
    );
  }
}
