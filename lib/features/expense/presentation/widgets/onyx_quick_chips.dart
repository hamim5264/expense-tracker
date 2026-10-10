import 'package:flutter/material.dart';

class OnyxQuickChips extends StatelessWidget {
  final List<String> chips;
  final bool isDark;
  final Function(String) onChipSelected;

  const OnyxQuickChips({
    super.key,
    required this.chips,
    required this.isDark,
    required this.onChipSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E1B29) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.shade200;

    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 8, bottom: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final chip = chips[idx];
          return ActionChip(
            backgroundColor: cardBg,
            side: BorderSide(color: borderColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            label: Text(
              chip,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            onPressed: () => onChipSelected(chip),
          );
        },
      ),
    );
  }
}
