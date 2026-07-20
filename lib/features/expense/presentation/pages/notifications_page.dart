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

  IconData _getIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle_outline_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'info':
      default:
        return Icons.info_outline_rounded;
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

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F9FB);
    final cardBg = isDark ? const Color(0xFF1E1E2C) : Colors.white;
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
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
                    Icons.mark_chat_read_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await service.markAllAsRead();
                  },
                ),
                IconButton(
                  tooltip: 'Clear all',
                  icon: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear All Notifications'),
                        content: const Text(
                          'Are you sure you want to delete all notifications?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
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
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'All caught up!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No new notifications at the moment.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
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
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (!item.isRead) {
                            service.markAsRead(item.id);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: item.isRead
                                  ? Colors.transparent
                                  : itemColor.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.05 : 0.03,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: itemColor.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getIcon(item.type),
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
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatTime(item.timestamp),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? Colors.white60
                                                : Colors.grey,
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
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!item.isRead) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: BoxDecoration(
                                    color: itemColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
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
