import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/common/utils/notification_service.dart';

class NotificationCardWidget extends StatelessWidget {
  final AppNotification notification;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    required this.isDark,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  IconData _getIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('update')) return Icons.system_update_alt_rounded;
    if (t.contains('announcement') || t.contains('community')) {
      return Icons.favorite_border_rounded;
    }
    if (t.contains('feature')) return Icons.layers_rounded;
    if (t.contains('budget')) return CupertinoIcons.chart_pie_fill;
    if (t.contains('loan')) return Icons.account_balance_outlined;
    return Icons.notifications_active_outlined;
  }

  String _getCategoryLabel(String type) {
    final t = type.toLowerCase();
    if (t.contains('update')) return 'Update';
    if (t.contains('announcement')) return 'Community';
    if (t.contains('feature')) return 'Release';
    if (t.contains('budget')) return 'Budget';
    if (t.contains('loan')) return 'Loan';
    return 'Notification';
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    final icon = _getIcon(notification.type);
    final category = _getCategoryLabel(notification.type);

    final cardBg = unread
        ? (isDark ? const Color(0xFF1E192F) : const Color(0xFFFCF7FF))
        : (isDark ? const Color(0xFF161422) : Colors.white);

    final borderColor = unread
        ? (isDark ? const Color(0xFF48356E) : const Color(0xFFE8D5FF))
        : (isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF0EDF6));

    final iconBg = unread
        ? (isDark ? const Color(0xFF332352) : const Color(0xFFEDE0FF))
        : (isDark ? const Color(0xFF381F38) : const Color(0xFFFCE7F5));

    final iconColor = unread
        ? const Color(0xFF8152D5)
        : const Color(0xFFED4BA8);

    final textColor = isDark ? Colors.white : const Color(0xFF201B38);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF77728E);
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF49435F);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6540A0).withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Pink left accent indicator for unread notifications
            if (unread)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFFED4BA8),
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(24),
                    ),
                  ),
                ),
              ),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Icon + Content Column (Title, New Badge, Menu, Date)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              icon,
                              size: 24,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title Row with 3-dot Menu at top-right
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 14.5,
                                          height: 1.3,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        CupertinoIcons.ellipsis_vertical,
                                        color: secondaryTextColor,
                                        size: 16,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onSelected: (value) {
                                        if (value == 'read') {
                                          onMarkAsRead();
                                        } else if (value == 'delete') {
                                          onDelete();
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        if (unread)
                                          const PopupMenuItem(
                                            value: 'read',
                                            child: Row(
                                              children: [
                                                Icon(
                                                    CupertinoIcons
                                                        .checkmark_alt,
                                                    size: 18),
                                                SizedBox(width: 8),
                                                Text('Mark as read'),
                                              ],
                                            ),
                                          ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(CupertinoIcons.trash,
                                                  size: 18, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),

                                // Date & Category Tag + "New" Badge Row
                                Row(
                                  children: [
                                    Text(
                                      '${_formatDate(notification.timestamp)} • $category',
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (unread) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE2F3),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'New',
                                          style: TextStyle(
                                            color: Color(0xFFED4BA8),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Description Text & Trailing Action Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              notification.message,
                              style: TextStyle(
                                color: bodyColor,
                                fontSize: 13,
                                height: 1.48,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2442) : const Color(0xFFF0E5FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.chevron_right,
                              color: Color(0xFF8152D5),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
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
