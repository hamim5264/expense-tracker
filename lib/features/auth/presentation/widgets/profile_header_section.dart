import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:expense_tracker/core/routing/app_router.dart';
import 'package:expense_tracker/core/common/utils/notification_service.dart';

class ProfileHeaderSection extends StatelessWidget {
  final dynamic user;
  final VoidCallback? onBackTap;
  final VoidCallback onAvatarTap;

  const ProfileHeaderSection({
    super.key,
    required this.user,
    this.onBackTap,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.primaryColor.computeLuminance() > 0.45;
    final headerTextColor = isLight ? const Color(0xFF1F2937) : Colors.white;

    return Stack(
      children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 280),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (onBackTap != null) {
                          onBackTap!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: headerTextColor,
                      ),
                    ),
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: headerTextColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: NotificationService(),
                      builder: (context, _) {
                        final unread = NotificationService().unreadCount;
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.notifications,
                            );
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  CupertinoIcons.bell,
                                  color: headerTextColor,
                                  size: 24,
                                ),
                              ),
                              if (unread > 0)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context).primaryColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      unread > 9 ? '9+' : '$unread',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Center(
                child: GestureDetector(
                  onTap: onAvatarTap,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: user.avatarUrl == null
                              ? theme.primaryColor.withAlpha(60)
                              : Colors.white,
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Icon(
                                  CupertinoIcons.person_fill,
                                  size: 50,
                                  color: theme.primaryColor,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            CupertinoIcons.camera_fill,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Center(
                child: Text(
                  user.username != null && user.username!.trim().isNotEmpty
                      ? '@${user.username}'
                      : 'Set username',
                  style: TextStyle(
                    color: user.username != null &&
                            user.username!.trim().isNotEmpty
                        ? (theme.primaryColor.computeLuminance() > 0.5
                            ? Colors.black54
                            : Colors.white70)
                        : Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
