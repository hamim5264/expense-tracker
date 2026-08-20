import 'package:flutter/cupertino.dart';
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
import 'package:expense_tracker/features/auth/presentation/pages/report_issue_page.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/avatar_picker_sheet.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/profile_header_section.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/invite_friends_sheet.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/glass_theme_selector.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/glass_color_selector.dart';
import 'package:expense_tracker/core/common/utils/theme_service.dart';
import 'package:expense_tracker/core/common/utils/notification_service.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/glass_currency_selector.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/sms_import_sheet.dart';
import 'package:expense_tracker/features/expense/presentation/pages/expense_reports_page.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/clear_transaction_history_sheet.dart';
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

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 22, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: isDark ? Colors.white54 : Colors.grey.shade600,
        ),
      ),
    );
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
    final rawPrimary = theme.primaryColor;
    final isDarkPrimary = rawPrimary.computeLuminance() < 0.25;

    final iconColor = (isDark && isDarkPrimary)
        ? Colors.purpleAccent.shade100
        : rawPrimary;
    final switchActiveColor = (isDark && isDarkPrimary)
        ? Colors.purpleAccent.shade100
        : rawPrimary;
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
                      _buildSectionHeader('COMMUNITY & REWARDS', isDark),
                      ProfileOptionTile(
                        icon: CupertinoIcons.sparkles,
                        title: 'Invite Friends',
                        subtitle: 'Share Onyx with friends & family',
                        iconColor: Colors.teal.shade400,
                        showBackgroundBox: true,
                        showTrailingArrow: true,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            barrierColor: Colors.black.withAlpha(80),
                            builder: (context) => const InviteFriendsSheet(),
                          );
                        },
                      ),

                      _buildSectionHeader('ACCOUNT & SECURITY', isDark),
                      ProfileOptionTile(
                        icon: CupertinoIcons.person_crop_circle,
                        title: 'Account Info',
                        subtitle: 'Manage profile details',
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
                        icon: CupertinoIcons.lock_shield,
                        title: 'Login and Security',
                        subtitle: 'Password & security options',
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
                        icon: CupertinoIcons.shield_fill,
                        title: 'Data and Privacy',
                        subtitle: 'Data & privacy preferences',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        showTrailingArrow: true,
                        onTap: () {
                          Navigator.push(context, DataPrivacyPage.route());
                        },
                      ),

                      _buildSectionHeader('REPORTS & STATEMENTS', isDark),
                      ProfileOptionTile(
                        icon: CupertinoIcons.doc_text_fill,
                        title: 'Expense Reports',
                        subtitle: 'View & open PDF statements',
                        iconColor: Colors.redAccent,
                        showBackgroundBox: true,
                        showTrailingArrow: true,
                        onTap: () {
                          Navigator.push(context, ExpenseReportsPage.route());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: dividerColor),
                      ),
                      ProfileOptionTile(
                        icon: CupertinoIcons.trash_circle_fill,
                        title: 'Clear Transaction History',
                        subtitle: 'Clear expense or income logs',
                        iconColor: Colors.orangeAccent.shade400,
                        showBackgroundBox: true,
                        showTrailingArrow: true,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            barrierColor: Colors.black.withAlpha(80),
                            builder: (sheetContext) => ClearTransactionHistorySheet(
                              userId: user.id,
                            ),
                          );
                        },
                      ),

                      _buildSectionHeader('PREFERENCES & APPEARANCE', isDark),
                      ProfileOptionTile(
                        icon: CupertinoIcons.money_dollar_circle,
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
                            icon: CupertinoIcons.paintbrush,
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
                            icon: CupertinoIcons.color_filter,
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
                      AnimatedBuilder(
                        animation: NotificationService(),
                        builder: (context, _) {
                          final isEnabled = NotificationService().isNotificationsEnabled;
                          return ProfileOptionTile(
                            icon: CupertinoIcons.bell_fill,
                            title: 'Notifications',
                            subtitle: isEnabled ? 'Enabled' : 'Disabled',
                            iconColor: Colors.purpleAccent,
                            showBackgroundBox: true,
                            trailing: CupertinoSwitch(
                              value: isEnabled,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (val) {
                                NotificationService().setNotificationsEnabled(val);
                              },
                            ),
                            onTap: () {
                              NotificationService().setNotificationsEnabled(!isEnabled);
                            },
                          );
                        },
                      ),

                      _buildSectionHeader('DATA INTEGRATION & SYNC', isDark),
                      ProfileOptionTile(
                        icon: CupertinoIcons.doc_text_viewfinder,
                        title: 'Paste & Parse Bank SMS',
                        subtitle: 'Convert SMS to expense',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        showTrailingArrow: true,
                        onTap: () {
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
                            builder: (sheetContext) => SmsImportSheet(
                              userId: user.id,
                              wallets: wallets,
                            ),
                          );
                        },
                      ),

                      _buildSectionHeader('AUDIO & HAPTICS', isDark),
                      ProfileOptionTile(
                        icon: CupertinoIcons.speaker_2,
                        title: 'Sound Effects',
                        subtitle: 'Play operational sound effects',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        trailing: Switch(
                          value: SoundService.soundEnabled,
                          activeThumbColor: isDark ? Colors.white : switchActiveColor,
                          activeTrackColor: switchActiveColor.withOpacity(0.55),
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
                        icon: CupertinoIcons.waveform_circle,
                        title: 'Haptic Vibration',
                        subtitle: 'Vibrate device on touch actions',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        trailing: Switch(
                          value: SoundService.vibrateEnabled,
                          activeThumbColor: isDark ? Colors.white : switchActiveColor,
                          activeTrackColor: switchActiveColor.withOpacity(0.55),
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

                      _buildSectionHeader('SUPPORT & LEGAL', isDark),
                      ProfileOptionTile(
                        icon: CupertinoIcons.doc_plaintext,
                        title: 'Privacy Policy',
                        subtitle: 'Privacy policy & data usage rules',
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
                        icon: CupertinoIcons.trash,
                        title: 'Data Deletion Instructions',
                        subtitle: 'Account & data removal guide',
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
                        icon: CupertinoIcons.headphones,
                        title: 'Contact Support',
                        subtitle: 'Get support & submit requests',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        showTrailingArrow: true,
                        onTap: () {
                          Navigator.push(context, ContactSupportPage.route());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: dividerColor),
                      ),
                      ProfileOptionTile(
                        icon: CupertinoIcons.ant,
                        title: 'Report Issue or Feedback',
                        subtitle: 'Share feedback or report bugs',
                        iconColor: iconColor,
                        showBackgroundBox: true,
                        showTrailingArrow: true,
                        onTap: () {
                          Navigator.push(context, ReportIssuePage.route());
                        },
                      ),

                      const SizedBox(height: 24),
                      ProfileOptionTile(
                        icon: CupertinoIcons.square_arrow_right,
                        title: 'Logout',
                        isDestructive: true,
                        showBackgroundBox: true,
                        showTrailingArrow: false,
                        onTap: () {
                          context.read<AuthBloc>().add(AuthLogout());
                        },
                      ),
                      const SizedBox(height: 120),
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
