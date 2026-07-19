import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/core/routing/app_router.dart';
import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:expense_tracker/features/auth/presentation/pages/profile_info_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_security_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/data_privacy_page.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/profile_option_tile.dart';
import 'package:expense_tracker/features/auth/presentation/pages/privacy_policy_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/data_deletion_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/contact_support_page.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/avatar_picker_sheet.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/profile_header_section.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/invite_friends_sheet.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/glass_theme_selector.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/glass_color_selector.dart';
import 'package:expense_tracker/core/common/utils/theme_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/glass_currency_selector.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/sms_import_sheet.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/common/utils/sound_service.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onBackTap;

  const ProfilePage({super.key, this.onBackTap});

  static Route route() =>
      MaterialPageRoute(builder: (context) => const ProfilePage());

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.system:
        return 'System Default (Follow System)';
    }
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(80),
      builder: (sheetContext) {
        return GlassThemeSelector(
          selectedMode: ThemeService.themeModeNotifier.value,
          onThemeSelected: (mode) {
            ThemeService.setThemeMode(mode);
          },
        );
      },
    );
  }

  String _getColorName(Color color) {
    if (color.value == const Color(0xFF4F378A).value) return 'Amethyst Purple';
    if (color.value == const Color(0xFF0F9B0F).value) return 'Emerald Green';
    if (color.value == const Color(0xFF0083B0).value) return 'Ocean Blue';
    if (color.value == const Color(0xFFFF5858).value) return 'Sunset Crimson';
    if (color.value == const Color(0xFF232526).value) return 'Obsidian Dark';
    if (color.value == const Color(0xFFD4AF37).value) return 'Golden Amber';
    return 'Custom Color';
  }

  void _showColorThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(80),
      builder: (sheetContext) {
        return GlassColorSelector(
          selectedColor: ThemeService.primaryColorNotifier.value,
          onColorSelected: (color) {
            ThemeService.setPrimaryColor(color);
          },
        );
      },
    );
  }

  Future<void> _toggleSmsSync(
    BuildContext context,
    dynamic user,
    bool value,
  ) async {
    if (value) {
      final status = await Permission.sms.request();
      if (status.isGranted) {
        if (context.mounted) {
          context.read<AuthBloc>().add(
            AuthUpdateUserProfile(
              name: user.name,
              username: user.username,
              avatarUrl: user.avatarUrl,
              currency: user.currency,
              smsSyncEnabled: true,
            ),
          );

          final expenseState = context.read<ExpenseBloc>().state;
          List<Wallet> wallets = [];
          if (expenseState is ExpenseSuccess) {
            wallets = expenseState.wallets;
          }
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            barrierColor: Colors.black.withAlpha(80),
            builder: (sheetContext) =>
                SmsImportSheet(userId: user.id, wallets: wallets),
          );
        }
      } else {
        showToast('SMS Permission denied!', isError: true);
      }
    } else {
      context.read<AuthBloc>().add(
        AuthUpdateUserProfile(
          name: user.name,
          username: user.username,
          avatarUrl: user.avatarUrl,
          currency: user.currency,
          smsSyncEnabled: false,
        ),
      );
    }
  }

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
            return Column(
              children: [
                ProfileHeaderSection(
                  user: user,
                  onBackTap: widget.onBackTap,
                  onAvatarTap: () => _showAvatarPicker(
                    context,
                    user.avatarUrl,
                    user.name,
                    user.username,
                  ),
                ),
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
                            builder: (context) => const InviteFriendsSheet(),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: dividerColor),
                      ),
                      ProfileOptionTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Account Info',
                        subtitle: 'Manage your profile details',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        showTrailingArrow: true,
                        onTap: () {
                          Navigator.push(context, ProfileInfoPage.route());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: dividerColor),
                      ),
                      ProfileOptionTile(
                        icon: Icons.security_outlined,
                        title: 'Login and Security',
                        subtitle: 'Password and security options',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        showTrailingArrow: true,
                        onTap: () {
                          Navigator.push(context, LoginSecurityPage.route());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: dividerColor),
                      ),
                      ProfileOptionTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Data and Privacy',
                        subtitle: 'Manage your data preferences',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        showTrailingArrow: true,
                        onTap: () {
                          Navigator.push(context, DataPrivacyPage.route());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: dividerColor),
                      ),
                      ProfileOptionTile(
                        icon: Icons.monetization_on_outlined,
                        title: 'Preferred Currency',
                        subtitle: user.currency,
                        iconColor: Colors.amber.shade700,
                        showBackgroundBox: true,
                        showTrailingArrow: true,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            barrierColor: Colors.black.withAlpha(80),
                            builder: (sheetContext) {
                              return GlassCurrencySelector(
                                selectedCurrency: user.currency,
                                onCurrencySelected: (cur) {
                                  context.read<AuthBloc>().add(
                                    AuthUpdateUserProfile(
                                      name: user.name,
                                      username: user.username,
                                      avatarUrl: user.avatarUrl,
                                      currency: cur,
                                      smsSyncEnabled: user.smsSyncEnabled,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: dividerColor),
                      ),
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: ThemeService.themeModeNotifier,
                        builder: (context, currentMode, _) {
                          return ProfileOptionTile(
                            icon: Icons.palette_outlined,
                            title: 'Theme Mode',
                            subtitle: _getThemeModeName(currentMode),
                            iconColor: Colors.blue.shade700,
                            showBackgroundBox: true,
                            showTrailingArrow: true,
                            onTap: () => _showThemeSelector(context),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: dividerColor),
                      ),
                      ValueListenableBuilder<Color>(
                        valueListenable: ThemeService.primaryColorNotifier,
                        builder: (context, primaryColor, _) {
                          return ProfileOptionTile(
                            icon: Icons.color_lens_outlined,
                            title: 'Theme Color',
                            subtitle: _getColorName(primaryColor),
                            iconColor: primaryColor,
                            showBackgroundBox: true,
                            showTrailingArrow: true,
                            onTap: () => _showColorThemeSelector(context),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: dividerColor),
                      ),
                      ProfileOptionTile(
                        icon: Icons.sms_outlined,
                        title: 'SMS Expense Sync',
                        subtitle: 'Scan inbox to auto-detect expenses',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        trailing: Switch(
                          value: user.smsSyncEnabled,
                          activeThumbColor: iconColor,
                          activeTrackColor: iconColor.withAlpha(120),
                          onChanged: (bool value) =>
                              _toggleSmsSync(context, user, value),
                        ),
                        onTap: () =>
                            _toggleSmsSync(context, user, !user.smsSyncEnabled),
                      ),
                      if (user.smsSyncEnabled) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(height: 1, color: dividerColor),
                        ),
                        ProfileOptionTile(
                          icon: Icons.download_rounded,
                          title: 'Import SMS Transactions',
                          subtitle: 'Manually import detected transactions',
                          iconColor: iconColor,
                          showBackgroundBox: true,
                          showTrailingArrow: true,
                          onTap: () {
                            final expenseState = context
                                .read<ExpenseBloc>()
                                .state;
                            List<Wallet> wallets = [];
                            if (expenseState is ExpenseSuccess) {
                              wallets = expenseState.wallets;
                            }
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              barrierColor: Colors.black.withAlpha(80),
                              builder: (sheetContext) => SmsImportSheet(
                                userId: user.id,
                                wallets: wallets,
                              ),
                            );
                          },
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: dividerColor),
                      ),
                      ProfileOptionTile(
                        icon: Icons.volume_up_outlined,
                        title: 'Sound Effects',
                        subtitle: 'Play sounds on app operations',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        trailing: Switch(
                          value: SoundService.soundEnabled,
                          activeThumbColor: iconColor,
                          activeTrackColor: iconColor.withAlpha(120),
                          onChanged: (bool value) {
                            setState(() {
                              SoundService.setSoundEnabled(value);
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            SoundService.setSoundEnabled(
                              !SoundService.soundEnabled,
                            );
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: dividerColor),
                      ),
                      ProfileOptionTile(
                        icon: Icons.vibration_outlined,
                        title: 'Haptic Vibration',
                        subtitle: 'Vibrate device on actions',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        trailing: Switch(
                          value: SoundService.vibrateEnabled,
                          activeThumbColor: iconColor,
                          activeTrackColor: iconColor.withAlpha(120),
                          onChanged: (bool value) {
                            setState(() {
                              SoundService.setVibrateEnabled(value);
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            SoundService.setVibrateEnabled(
                              !SoundService.vibrateEnabled,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'Support & Legal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white60
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      ProfileOptionTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'Read our privacy policy & data usage rules',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        showTrailingArrow: true,
                        onTap: () {
                          Navigator.push(context, PrivacyPolicyPage.route());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: dividerColor),
                      ),
                      ProfileOptionTile(
                        icon: Icons.delete_forever_outlined,
                        title: 'Data Deletion Instructions',
                        subtitle: 'Learn how to request data removal',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        showTrailingArrow: true,
                        onTap: () {
                          Navigator.push(context, DataDeletionPage.route());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: dividerColor),
                      ),
                      ProfileOptionTile(
                        icon: Icons.support_agent_outlined,
                        title: 'Contact Support',
                        subtitle: 'Get support or submit manual requests',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        showTrailingArrow: true,
                        onTap: () {
                          Navigator.push(context, ContactSupportPage.route());
                        },
                      ),
                      const SizedBox(height: 20),
                      ProfileOptionTile(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        isDestructive: true,
                        showBackgroundBox: true,
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
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
