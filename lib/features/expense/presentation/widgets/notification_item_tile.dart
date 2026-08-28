import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/common/utils/notification_service.dart';

class NotificationItemTile extends StatelessWidget {
  final AppNotification item;
  final bool isDark;
  final Color textColor;
  final String formattedTime;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationItemTile({
    super.key,
    required this.item,
    required this.isDark,
    required this.textColor,
    required this.formattedTime,
    required this.onTap,
    required this.onDelete,
  });

  IconData _getCupertinoIcon(String type) {
    switch (type) {
      case 'success':
        return CupertinoIcons.checkmark_alt_circle_fill;
      case 'warning':
        return CupertinoIcons.exclamationmark_triangle_fill;
      case 'update':
        return CupertinoIcons.arrow_down_square_fill;
      case 'info':
      default:
        return CupertinoIcons.info_circle_fill;
    }
  }

  Color _getColor(String type, BuildContext context) {
    switch (type) {
      case 'success':
        return const Color(0xFF22C55E);
      case 'warning':
        return const Color(0xFFF59E0B);
      case 'update':
        return const Color(0xFFEC4899);
      case 'info':
      default:
        return Theme.of(context).primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemColor = _getColor(item.type, context);
    final iconData = _getCupertinoIcon(item.type);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          CupertinoIcons.trash,
          color: Colors.white,
          size: 20,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: item.isRead
              ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
              : (isDark ? const Color(0xFF282538) : itemColor.withOpacity(0.08)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead
                ? (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05))
                : itemColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: itemColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      color: itemColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                  color: textColor,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.message,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: isDark ? Colors.white70 : Colors.black87.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!item.isRead) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: itemColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: itemColor.withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
