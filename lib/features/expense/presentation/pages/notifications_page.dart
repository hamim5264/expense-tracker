import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_tracker/core/common/utils/notification_service.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/notifications_header_widget.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/notifications_filter_bar.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/notification_card_widget.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/notifications_empty_widget.dart';

class NotificationsPage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const NotificationsPage());

  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _selectedFilter = 'All';

  bool _matchesFilter(AppNotification n, String filter) {
    if (filter == 'All') return true;
    final t = n.type.toLowerCase();
    if (filter == 'Updates') return t.contains('update');
    if (filter == 'Announcements') {
      return t.contains('announcement') || t.contains('community');
    }
    if (filter == 'Features') return t.contains('feature');
    return true;
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    NotificationService service,
    AppNotification item,
  ) async {
    if (!item.isRead) {
      await service.markAsRead(item.id);
    }
    if (item.linkUrl != null && item.linkUrl!.trim().isNotEmpty) {
      final uri = Uri.parse(item.linkUrl!.trim());
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    NotificationService service,
    bool isDark,
  ) async {
    if (service.notifications.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1B29) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          'Delete all notifications?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF201B38),
          ),
        ),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF77728E),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text(
              'Delete all',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await service.clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final service = NotificationService();
    final bgColor = isDark ? const Color(0xFF12111A) : const Color(0xFFF9F7FD);

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final allItems = service.notifications;
        final filteredList =
            allItems.where((n) => _matchesFilter(n, _selectedFilter)).toList();

        return Scaffold(
          backgroundColor: bgColor,
          body: Column(
            children: [
              // 1. Purple Gradient Header with 3D Bell & Counter
              NotificationsHeaderWidget(
                unreadCount: service.unreadCount,
                totalCount: allItems.length,
                onBack: () => Navigator.pop(context),
                onMarkAllRead: () async => await service.markAllAsRead(),
                onDeleteAll: () =>
                    _showDeleteConfirmation(context, service, isDark),
              ),

              // 2. Horizontal Category Filter Chips Bar
              NotificationsFilterBar(
                selectedFilter: _selectedFilter,
                onFilterSelected: (val) => setState(() => _selectedFilter = val),
                isDark: isDark,
              ),

              // 3. Notification Cards List / Empty State
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF8152D5),
                  onRefresh: () async {
                    await service.fetchRemoteAnnouncements();
                  },
                  child: filteredList.isEmpty
                      ? NotificationsEmptyWidget(isDark: isDark)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            return NotificationCardWidget(
                              notification: item,
                              isDark: isDark,
                              onTap: () =>
                                  _handleNotificationTap(context, service, item),
                              onMarkAsRead: () async =>
                                  await service.markAsRead(item.id),
                              onDelete: () async =>
                                  await service.deleteNotification(item.id),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
