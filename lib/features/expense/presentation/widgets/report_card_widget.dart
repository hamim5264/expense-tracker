import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/common/utils/report_storage_service.dart';

class ReportCardWidget extends StatelessWidget {
  final SavedReport report;
  final VoidCallback onPreview;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const ReportCardWidget({
    super.key,
    required this.report,
    required this.onPreview,
    required this.onDownload,
    required this.onDelete,
  });

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthNames[dt.month - 1];
    final year = dt.year;
    final hourInt = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final hour = hourInt.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';

    return '$day $month $year, $hour:$minute $period';
  }

  String _getDisplayTitle(SavedReport report) {
    final p = report.period.trim();
    final lower = p.toLowerCase();

    if (lower.contains('all transactions')) {
      return 'All Transactions Statement';
    }
    if (lower == 'expense report' || lower == 'expense') {
      return 'Expense Report';
    }
    if (lower == 'income report' || lower == 'income') {
      return 'Income Report';
    }
    if (lower.endsWith(' all')) {
      final base = p.substring(0, p.length - 4).trim();
      return '$base Statement';
    }
    if (lower.endsWith(' expense')) {
      final base = p.substring(0, p.length - 8).trim();
      return '$base Expense Report';
    }
    if (lower.endsWith(' income')) {
      final base = p.substring(0, p.length - 7).trim();
      return '$base Income Report';
    }
    if (lower.contains('statement') || lower.contains('report')) {
      return p;
    }
    return '$p Statement';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E1A2C) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2F2942) : const Color(0xFFE9DFFF);
    final textColor = isDark ? Colors.white : const Color(0xFF211B38);
    final secondaryTextColor = isDark ? const Color(0xFFA69EB8) : const Color(0xFF817A9B);
    final badgeBg = isDark ? const Color(0xFF29223D) : const Color(0xFFF0E7FF);
    final primaryPurple = const Color(0xFF563294);
    final primaryLight = const Color(0xFF8B4BD1);

    final title = _getDisplayTitle(report);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.24)
                : primaryPurple.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onPreview,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Red PDF Icon, Title & Date, and 3-dot Menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Red PDF Document Icon Box
                    Container(
                      width: 50,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3B1E26) : const Color(0xFFFFE8EA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.doc_text_fill,
                          color: Color(0xFFFF5263),
                          size: 28,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Center Information: Title and Date take full width up to 3-dot menu
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Report Title (shows fully without constriction)
                          Text(
                            title,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              letterSpacing: -0.2,
                            ),
                          ),

                          const SizedBox(height: 5),

                          // Generation Date & Time
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.calendar,
                                size: 13.5,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  _formatDateTime(report.generatedAt),
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 4),

                    // 3-dot Menu
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: isDark ? const Color(0xFF262137) : Colors.white,
                      icon: Icon(
                        CupertinoIcons.ellipsis_vertical,
                        color: textColor,
                        size: 20,
                      ),
                      onSelected: (value) {
                        if (value == 'download') {
                          onDownload();
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'download',
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.share,
                                size: 18,
                                color: textColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Open externally',
                                style: TextStyle(color: textColor, fontSize: 13.5),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.trash,
                                size: 18,
                                color: Color(0xFFFF5263),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Delete report',
                                style: TextStyle(
                                  color: Color(0xFFFF5263),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom Row: App Reports Badge & Action Buttons
                Row(
                  children: [
                    // App Reports • Size Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.arrow_down_to_line,
                            color: primaryLight,
                            size: 12.5,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'App Reports • ${report.formattedSize}',
                            style: TextStyle(
                              color: isDark ? const Color(0xFFC9B6EB) : primaryPurple,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Preview (Eye) Button
                    _buildActionCircle(
                      icon: CupertinoIcons.eye_fill,
                      isPrimary: false,
                      isDark: isDark,
                      onTap: onPreview,
                      tooltip: 'Preview Report',
                    ),

                    const SizedBox(width: 8),

                    // Download / Share Button
                    _buildActionCircle(
                      icon: CupertinoIcons.arrow_down_to_line,
                      isPrimary: true,
                      isDark: isDark,
                      onTap: onDownload,
                      tooltip: 'Download & Open',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCircle({
    required IconData icon,
    required bool isPrimary,
    required bool isDark,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    final bgColor = isPrimary
        ? null
        : (isDark ? const Color(0xFF2B243E) : const Color(0xFFF0E5FF));
    final iconColor = isPrimary
        ? Colors.white
        : (isDark ? const Color(0xFFC7B1F3) : const Color(0xFF563294));

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor,
              gradient: isPrimary
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF8B4BD1),
                        Color(0xFF563294),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              shape: BoxShape.circle,
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: const Color(0xFF563294).withOpacity(0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

