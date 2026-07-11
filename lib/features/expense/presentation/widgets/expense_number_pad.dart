import 'package:flutter/material.dart';

class ExpenseNumberPad extends StatelessWidget {
  final ValueChanged<String> onKeyPress;

  const ExpenseNumberPad({super.key, required this.onKeyPress});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildKeyboardRow(['1', '2', '3']),
          _buildKeyboardRow(['4', '5', '6']),
          _buildKeyboardRow(['7', '8', '9']),
          _buildKeyboardRow(['.', '0', 'back']),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: keys.map((key) {
          if (key == 'back') {
            return _buildKeyWidget(
              const Icon(Icons.backspace_outlined, color: Colors.grey),
              () => onKeyPress('back'),
            );
          }
          return _buildKeyWidget(
            Text(
              key,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            () => onKeyPress(key),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyWidget(Widget child, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(alignment: Alignment.center, height: 54, child: child),
      ),
    );
  }
}
