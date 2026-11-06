import 'package:expense_tracker/core/services/onyx_invite_service.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/invite_friends_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnyxAiLockedView extends StatelessWidget {
  final bool isDark;
  final Color primaryColor;

  const OnyxAiLockedView({
    super.key,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final cardBg = isDark ? const Color(0xFF1E1B29) : Colors.white;

    return ValueListenableBuilder<int>(
      valueListenable: OnyxInviteService.inviteCountNotifier,
      builder: (context, count, _) {
        final remaining = (OnyxInviteService.requiredInvites - count).clamp(0, OnyxInviteService.requiredInvites);

        return Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Icon Shield
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        primaryColor.withOpacity(0.55),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.35),
                        blurRadius: 28,
                        spreadRadius: 4,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.lock_shield_fill,
                      size: 46,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title & Subtitle
                Text(
                  'Unlock Onyx AI 2.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your private neural financial advisor with real-time health score, smart run-rate forecasts, and interactive chat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 28),

                // 5-Dots Progress Indicator Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.person_2_fill,
                                size: 16,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Invite Progress',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$count / ${OnyxInviteService.requiredInvites} Friends',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 5 Visual Progress Dots
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final dotSize = ((constraints.maxWidth - 36) / OnyxInviteService.requiredInvites)
                              .clamp(34.0, 44.0);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(OnyxInviteService.requiredInvites, (index) {
                              final isAchieved = index < count;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: dotSize,
                                height: dotSize,
                                decoration: BoxDecoration(
                                  color: isAchieved
                                      ? primaryColor
                                      : (isDark
                                          ? Colors.white.withOpacity(0.06)
                                          : Colors.grey.shade100),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isAchieved
                                        ? primaryColor
                                        : (isDark ? Colors.white12 : Colors.grey.shade300),
                                    width: 1.5,
                                  ),
                                  boxShadow: isAchieved
                                      ? [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: isAchieved
                                      ? const Icon(
                                          CupertinoIcons.checkmark_alt,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                            color: isDark ? Colors.white38 : Colors.grey.shade400,
                                          ),
                                        ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      Text(
                        remaining > 0
                            ? 'Invite $remaining more friend${remaining > 1 ? 's' : ''} to unlock AI for life.'
                            : 'All invitations complete! AI is unlocked.',
                        style: TextStyle(
                          fontSize: 12,
                          color: subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // CTA Button: Invite Friends
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(CupertinoIcons.share, size: 18),
                    label: Text(
                      'Invite Friends ($count/${OnyxInviteService.requiredInvites})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => const InviteFriendsSheet(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Feature Highlights
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _buildFeatureTag('Free AI Engine', CupertinoIcons.sparkles, textColor, subTextColor),
                      _buildFeatureTag('100% Offline First', CupertinoIcons.wifi_slash, textColor, subTextColor),
                      _buildFeatureTag('Zero Privacy Leak', CupertinoIcons.shield_lefthalf_fill, textColor, subTextColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureTag(String label, IconData icon, Color textColor, Color subColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: subColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: subColor,
          ),
        ),
      ],
    );
  }
}

