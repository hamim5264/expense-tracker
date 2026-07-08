import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/core/routing/app_router.dart';
import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:expense_tracker/features/auth/presentation/pages/profile_info_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_security_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/data_privacy_page.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/profile_option_tile.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/avatar_picker_sheet.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/invite_friends_sheet.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback? onBackTap;

  static Route route() =>
      MaterialPageRoute(builder: (context) => const ProfilePage());

  const ProfilePage({super.key, this.onBackTap});

  void _showAvatarPicker(
    BuildContext context,
    String? currentAvatar,
    String name,
    String? username,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(80),
      builder: (sheetContext) {
        return AvatarPickerSheet(
          selectedAvatar: currentAvatar,
          onAvatarSelected: (avatar) {
            context.read<AuthBloc>().add(
              AuthUpdateUserProfile(
                name: name,
                username: username,
                avatarUrl: avatar,
              ),
            );
            Navigator.pop(sheetContext);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.scaffoldBackgroundColor : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final iconColor = const Color(0xFF4F378A);
    final dividerColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: cardColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
          } else if (state is AuthFailure) {
            showToast(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is AuthSuccess) {
            final user = state.user;
            return Stack(
              children: [
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 280),
                  painter: HeaderPainter(),
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
                              onPressed: () {},
                              icon: const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                      Center(
                        child: GestureDetector(
                          onTap: () => _showAvatarPicker(
                            context,
                            user.avatarUrl,
                            user.name,
                            user.username,
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
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
                          user.username != null &&
                                  user.username!.trim().isNotEmpty
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
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            ProfileOptionTile(
                              icon: Icons.diamond_rounded,
                              title: 'Invite Friends',
                              iconColor: Colors.teal.shade400,
                              showBackgroundBox: true,
                              isCircle: true,
                              showTrailingArrow: false,
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  barrierColor: Colors.black.withAlpha(80),
                                  builder: (context) =>
                                      const InviteFriendsSheet(),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Divider(height: 1, color: dividerColor),
                            ),
                            ProfileOptionTile(
                              icon: Icons.person_outline_rounded,
                              title: 'Account info',
                              iconColor: iconColor,
                              showBackgroundBox: false,
                              showTrailingArrow: false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  ProfileInfoPage.route(),
                                );
                              },
                            ),
                            ProfileOptionTile(
                              icon: Icons.security_outlined,
                              title: 'Login and security',
                              iconColor: iconColor,
                              showBackgroundBox: false,
                              showTrailingArrow: false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  LoginSecurityPage.route(),
                                );
                              },
                            ),
                            ProfileOptionTile(
                              icon: Icons.lock_outline_rounded,
                              title: 'Data and privacy',
                              iconColor: iconColor,
                              showBackgroundBox: false,
                              showTrailingArrow: false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  DataPrivacyPage.route(),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            ProfileOptionTile(
                              icon: Icons.logout_rounded,
                              title: 'Logout',
                              isDestructive: true,
                              showBackgroundBox: false,
                              showTrailingArrow: false,
                              onTap: () {
                                context.read<AuthBloc>().add(AuthLogout());
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
