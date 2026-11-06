import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GenerateReportSheet extends StatelessWidget {
  final void Function(String type, DateTimeRange? dateRange) onSelectReportType;

  const GenerateReportSheet({
    super.key,
    required this.onSelectReportType,
  });

  static Future<void> show(
    BuildContext context, {
    required void Function(String type, DateTimeRange? dateRange) onSelectReportType,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GenerateReportSheet(
        onSelectReportType: onSelectReportType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1A2C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF211B38);
    final secondaryTextColor = isDark ? const Color(0xFFA69EB8) : const Color(0xFF817A9B);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 20;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(22, 14, 22, bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Title and Subtitle
              Text(
                'Generate Report',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a report type to generate.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 18),

              // Option 1: All Transactions
              _buildOption(
                context: context,
                icon: CupertinoIcons.doc_plaintext,
                title: 'All Transactions',
                subtitle: 'Full income & expense statement',
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  onSelectReportType('all', null);
                },
              ),

              const SizedBox(height: 10),

              // Option 2: Expense Report
              _buildOption(
                context: context,
                icon: CupertinoIcons.arrow_down_to_line,
                title: 'Expense Report',
                subtitle: 'View your spending history',
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  onSelectReportType('expense', null);
                },
              ),

              const SizedBox(height: 10),

              // Option 3: Income Report
              _buildOption(
                context: context,
                icon: CupertinoIcons.arrow_up_to_line,
                title: 'Income Report',
                subtitle: 'View your income & earnings',
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  onSelectReportType('income', null);
                },
              ),

              const SizedBox(height: 10),

              // Option 4: Custom Date Range
              _buildOption(
                context: context,
                icon: CupertinoIcons.calendar,
                title: 'Custom Date Range',
                subtitle: 'Pick custom start & end date',
                isDark: isDark,
                onTap: () async {
                  Navigator.pop(context);
                  const primaryColor = Color(0xFF563294);
                  final rangeBgColor = isDark
                      ? primaryColor.withOpacity(0.35)
                      : const Color(0xFFEDE4FA);
                  final surfaceColor =
                      isDark ? const Color(0xFF1E1A2C) : Colors.white;
                  final onSurfaceColor =
                      isDark ? Colors.white : const Color(0xFF211B38);

                  final chipButtonStyle = ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return isDark
                            ? const Color(0xFF2B263A)
                            : const Color(0xFFEFEFF2);
                      }
                      return primaryColor;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return isDark ? Colors.white38 : const Color(0xFF9E9E9E);
                      }
                      return Colors.white;
                    }),
                    textStyle: WidgetStateProperty.resolveWith((states) {
                      return TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: states.contains(WidgetState.disabled)
                            ? (isDark ? Colors.white38 : const Color(0xFF9E9E9E))
                            : Colors.white,
                      );
                    }),
                    foregroundBuilder: (context, states, child) {
                      final isDis = states.contains(WidgetState.disabled);
                      final txtColor = isDis
                          ? (isDark ? Colors.white38 : const Color(0xFF9E9E9E))
                          : Colors.white;
                      return DefaultTextStyle.merge(
                        style: TextStyle(
                          color: txtColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                        child: child ?? const SizedBox.shrink(),
                      );
                    },
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                    ),
                  );

                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                    builder: (pickerCtx, child) {
                      return Theme(
                        data: Theme.of(pickerCtx).copyWith(
                          scaffoldBackgroundColor: surfaceColor,
                          appBarTheme: AppBarTheme(
                            backgroundColor: surfaceColor,
                            elevation: 0,
                            iconTheme: IconThemeData(
                              color: onSurfaceColor,
                              size: 20,
                            ),
                            actionsPadding:
                                const EdgeInsets.only(right: 14),
                          ),
                          iconButtonTheme: IconButtonThemeData(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                isDark
                                    ? const Color(0xFF2C243E)
                                    : const Color(0xFFF0EAF9),
                              ),
                              foregroundColor: WidgetStateProperty.all(
                                isDark ? Colors.white : const Color(0xFF211B38),
                              ),
                              shape: WidgetStateProperty.all(
                                const CircleBorder(),
                              ),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.all(8),
                              ),
                              minimumSize: WidgetStateProperty.all(
                                const Size(38, 38),
                              ),
                              fixedSize: WidgetStateProperty.all(
                                const Size(38, 38),
                              ),
                            ),
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: chipButtonStyle,
                          ),
                          datePickerTheme: DatePickerThemeData(
                            confirmButtonStyle: chipButtonStyle,
                            rangeSelectionBackgroundColor: rangeBgColor,
                            rangeSelectionOverlayColor:
                                WidgetStateProperty.all(
                              primaryColor.withOpacity(0.08),
                            ),
                            rangePickerBackgroundColor: surfaceColor,
                            rangePickerHeaderBackgroundColor: surfaceColor,
                            rangePickerHeaderForegroundColor: onSurfaceColor,
                            rangePickerHeaderHeadlineStyle: TextStyle(
                              color: onSurfaceColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            rangePickerHeaderHelpStyle: TextStyle(
                              color: isDark
                                  ? const Color(0xFFA69EB8)
                                  : const Color(0xFF817A9B),
                              fontSize: 13,
                            ),
                            dayForegroundColor:
                                WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.white;
                              }
                              if (states.contains(WidgetState.disabled)) {
                                return isDark
                                    ? Colors.white24
                                    : Colors.grey.shade400;
                              }
                              return onSurfaceColor;
                            }),
                            dayBackgroundColor:
                                WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return primaryColor;
                              }
                              return null;
                            }),
                            todayForegroundColor:
                                WidgetStateProperty.all(primaryColor),
                            todayBorder: BorderSide(
                              color: primaryColor,
                              width: 1.5,
                            ),
                          ),
                          colorScheme: (isDark
                                  ? const ColorScheme.dark()
                                  : const ColorScheme.light())
                              .copyWith(
                            primary: primaryColor,
                            onPrimary: Colors.white,
                            secondary: rangeBgColor,
                            onSecondary: primaryColor,
                            secondaryContainer: rangeBgColor,
                            onSecondaryContainer: primaryColor,
                            surface: surfaceColor,
                            onSurface: onSurfaceColor,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    onSelectReportType('custom', picked);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    const primaryPurple = Color(0xFF563294);
    final itemBg = isDark ? const Color(0xFF252035) : const Color(0xFFFAF8FE);
    final borderColor = isDark ? const Color(0xFF332B47) : const Color(0xFFECE4FA);
    final textColor = isDark ? Colors.white : const Color(0xFF211B38);
    final secondaryTextColor = isDark ? const Color(0xFFA69EB8) : const Color(0xFF817A9B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: primaryPurple,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.chevron_right,
              color: primaryPurple,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

