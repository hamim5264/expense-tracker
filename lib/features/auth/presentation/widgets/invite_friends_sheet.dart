import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class InviteFriendsSheet extends StatelessWidget {
  const InviteFriendsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white60 : Colors.black54;

    final List<Map<String, dynamic>> platforms = [
      {
        'name': 'WhatsApp',
        'icon': Icons.chat_bubble_outline_rounded,
        'color': Colors.green.shade500,
      },
      {
        'name': 'Messenger',
        'icon': Icons.messenger_outline_rounded,
        'color': Colors.blue.shade500,
      },
      {
        'name': 'SMS',
        'icon': Icons.sms_outlined,
        'color': Colors.purple.shade400,
      },
      {
        'name': 'Email',
        'icon': Icons.mail_outline_rounded,
        'color': Colors.red.shade400,
      },
      {
        'name': 'Copy Link',
        'icon': Icons.link_rounded,
        'color': const Color(0xFF4F378A),
      },
    ];

    Future<void> handleTap(BuildContext context, String name) async {
      if (name == 'Copy Link') {
        Clipboard.setData(
          const ClipboardData(text: 'https://onyx-app.com/download'),
        );
        showToast('Download link copied to clipboard!');
      } else {
        final Uri url;
        if (name == 'WhatsApp') {
          url = Uri.parse(
            'whatsapp://send?text=Download%20Onyx%20app%20now:%20https://onyx-app.com/download',
          );
        } else if (name == 'Messenger') {
          url = Uri.parse('https://m.me/');
        } else if (name == 'SMS') {
          url = Uri.parse(
            'sms:?body=Download%20Onyx%20app%20now:%20https://onyx-app.com/download',
          );
        } else if (name == 'Email') {
          url = Uri.parse(
            'mailto:?subject=Try%20Onyx%20App&body=Download%20Onyx%20app%20now:%20https://onyx-app.com/download',
          );
        } else {
          return;
        }

        try {
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            if (name == 'WhatsApp') {
              final fallbackUrl = Uri.parse(
                'https://wa.me/?text=Download%20Onyx%20app%20now:%20https://onyx-app.com/download',
              );
              await launchUrl(
                fallbackUrl,
                mode: LaunchMode.externalApplication,
              );
            } else {
              showToast(
                'Could not open $name. Make sure the app is installed.',
                isError: true,
              );
            }
          }
        } catch (e) {
          showToast('Could not launch sharing option.', isError: true);
        }
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withAlpha(120)
                : Colors.white.withAlpha(200),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(30)
                  : Colors.black.withAlpha(15),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white30 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Invite Friends',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Share Onyx app with your friends and family',
                style: TextStyle(fontSize: 14, color: subColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: platforms.map((platform) {
                    return GestureDetector(
                      onTap: () => handleTap(context, platform['name']),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: platform['color'].withAlpha(25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: platform['color'].withAlpha(50),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              platform['icon'],
                              color: platform['color'],
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            platform['name'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
