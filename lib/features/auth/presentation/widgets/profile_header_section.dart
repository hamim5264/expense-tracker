import 'package:flutter/material.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:expense_tracker/core/routing/app_router.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

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
                  vertical: 8,
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
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.notifications);
                      },
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
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
                              ? const Color(0xFF4F378A).withAlpha(60)
                              : Colors.white,
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFFD1BCFF),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4F378A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              Center(
                child: Text(
                  user.username != null && user.username!.trim().isNotEmpty
                      ? '@${user.username}'
                      : 'Set username',
                  style: TextStyle(
                    color:
                        user.username != null &&
                            user.username!.trim().isNotEmpty
                        ? const Color(0xFF9E82F0)
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
