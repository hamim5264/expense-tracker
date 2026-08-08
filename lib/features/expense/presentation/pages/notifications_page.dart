import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/common/utils/notification_service.dart';

class NotificationsPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const NotificationsPage());

  const NotificationsPage({super.key});

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  IconData _getCupertinoIcon(String type) {
    switch (type) {
      case 'success':
        return CupertinoIcons.checkmark_alt_circle_fill;
      case 'warning':
        return CupertinoIcons.exclamationmark_triangle_fill;
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
      case 'info':
      default:
        return Theme.of(context).primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final service = NotificationService();

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final textColor = isDark ? Colors.white : Colors.black87;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final list = service.notifications;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: theme.primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            actions: [
              if (list.isNotEmpty) ...[
                IconButton(
                  tooltip: 'Mark all as read',
                  icon: const Icon(
                    CupertinoIcons.checkmark_seal_fill,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () async {
                    await service.markAllAsRead();
                  },
                ),
                IconButton(
                  tooltip: 'Clear all',
                  icon: const Icon(
                    CupertinoIcons.trash,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: isDark ? const Color(0xFF1E1B29) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text(
                          'Clear Notifications',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to delete all notifications?',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await service.clearAll();
                    }
                  },
                ),
              ],
            ],
          ),
          body: list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.bell_slash,
                          size: 56,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'All caught up!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No new notifications at the moment.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final itemColor = _getColor(item.type, context);

                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        service.deleteNotification(item.id);
                      },
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.only(right: 24),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          CupertinoIcons.trash,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (!item.isRead) {
                            service.markAsRead(item.id);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: isDark
                                ? LinearGradient(
                                    colors: [
                                      const Color(0xFF2A273A).withOpacity(0.95),
                                      const Color(0xFF1E1B29).withOpacity(0.95),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.white,
                                      const Color(0xFFF8F9FA),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            border: Border.all(
                              color: item.isRead
                                  ? (isDark
                                      ? Colors.white.withOpacity(0.08)
                                      : Colors.black.withOpacity(0.06))
                                  : itemColor.withOpacity(0.5),
                              width: item.isRead ? 1 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: itemColor.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: itemColor.withOpacity(0.25),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        _getCupertinoIcon(item.type),
                                        color: itemColor,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.title,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: item.isRead
                                                        ? FontWeight.w600
                                                        : FontWeight.bold,
                                                    color: textColor,
                                                    letterSpacing: 0.1,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatTime(item.timestamp),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? Colors.white54
                                                      : Colors.black45,
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
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black87.withOpacity(0.75),
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
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
