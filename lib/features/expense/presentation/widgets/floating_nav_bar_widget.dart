import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FloatingNavBarWidget extends StatelessWidget {
  final int selectedIndex;
  final bool isDark;
  final Color primaryColor;
  final ValueChanged<int> onTabSelected;

  const FloatingNavBarWidget({
    super.key,
    required this.selectedIndex,
    required this.isDark,
    required this.primaryColor,
    required this.onTabSelected,
  });

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = selectedIndex == index;

    final isLightPrimary = primaryColor.computeLuminance() > 0.55;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Icon(
          icon,
          color: isSelected
              ? (isDark
                  ? Colors.white
                  : (isLightPrimary ? const Color(0xFF333333) : primaryColor))
              : (isDark ? Colors.white38 : Colors.grey.shade600),
          size: isSelected ? 20 : 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double barWidth = 320;
    const double barHeight = 54;
    final isLightPrimary = primaryColor.computeLuminance() > 0.55;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Center(
            child: Container(
              width: barWidth,
              height: barHeight,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.45)
                    : Colors.white.withOpacity(0.94),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.18)
                      : Colors.black.withOpacity(0.08),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double totalWidth = constraints.maxWidth;
                  final double itemWidth = totalWidth / 5;
                  final double activePillWidth = itemWidth - 6;

                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        left: (selectedIndex * itemWidth) +
                            (itemWidth - activePillWidth) / 2,
                        top: (constraints.maxHeight - (constraints.maxHeight - 8)) /
                            2,
                        child: Container(
                          width: activePillWidth,
                          height: constraints.maxHeight - 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: isDark
                                ? Colors.white.withOpacity(0.20)
                                : (isLightPrimary
                                    ? primaryColor.withOpacity(0.60)
                                    : primaryColor.withOpacity(0.16)),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.15)
                                  : (isLightPrimary
                                      ? Colors.black.withOpacity(0.15)
                                      : primaryColor.withOpacity(0.30)),
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNavItem(CupertinoIcons.house_fill, 0),
                          ),
                          Expanded(
                            child: _buildNavItem(CupertinoIcons.chart_bar_fill, 1),
                          ),
                          Expanded(
                            child: _buildNavItem(CupertinoIcons.chart_pie_fill, 2),
                          ),
                          Expanded(
                            child: _buildNavItem(
                              CupertinoIcons.creditcard_fill,
                              3,
                            ),
                          ),
                          Expanded(
                            child: _buildNavItem(
                              CupertinoIcons.person_fill,
                              4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
