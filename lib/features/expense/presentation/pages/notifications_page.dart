import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_tracker/core/common/utils/notification_service.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/notification_item_tile.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/empty_notifications_placeholder.dart';

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
          body: Stack(
            children: [
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 220),
                painter: HeaderPainter(color: theme.primaryColor),
              ),
              Positioned(
                top: -20,
                left: -20,
                child: Opacity(
                  opacity: 0.80,
                  child: Image.asset(
                    'assets/images/components/background_design.png',
                    width: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              CupertinoIcons.back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Notifications',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
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
                                    backgroundColor: isDark
                                        ? const Color(0xFF1E1B29)
                                        : Colors.white,
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
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.redAccent,
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
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
                          ] else
                            const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: theme.primaryColor,
                        onRefresh: () async {
                          await service.fetchRemoteAnnouncements();
                        },
                        child: list.isEmpty
                            ? EmptyNotificationsPlaceholder(
                                isDark: isDark,
                                textColor: textColor,
                                primaryColor: theme.primaryColor,
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 100,
                                  bottom: 16,
                                ),
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  final item = list[index];

                                  return NotificationItemTile(
                                    item: item,
                                    isDark: isDark,
                                    textColor: textColor,
                                    formattedTime: _formatTime(item.timestamp),
                                    onTap: () async {
                                      if (!item.isRead) {
                                        await service.markAsRead(item.id);
                                      }
                                      if (item.linkUrl != null &&
                                          item.linkUrl!.trim().isNotEmpty) {
                                        final uri = Uri.parse(item.linkUrl!.trim());
                                        try {
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(
                                              uri,
                                              mode: LaunchMode.externalApplication,
                                            );
                                          }
                                        } catch (_) {}
                                      }
                                    },
                                    onDelete: () async {
                                      await service.deleteNotification(item.id);
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
