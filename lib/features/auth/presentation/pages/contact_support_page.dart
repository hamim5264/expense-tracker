import 'package:expense_tracker/core/common/utils/show_snackbar.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';

class ContactSupportPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const ContactSupportPage());

  const ContactSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.scaffoldBackgroundColor : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    const emails = ['hamim.leon@gmail.com'];

    Future<void> launchWhatsApp() async {
      final whatsappUri = Uri.parse('https://wa.me/8801724879284');
      try {
        final success = await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalNonBrowserApplication,
        );
        if (!success) {
          await launchUrl(whatsappUri, mode: LaunchMode.platformDefault);
        }
      } catch (e) {
        showToast('Error opening WhatsApp');
      }
    }

    return Scaffold(
      backgroundColor: cardColor,
      body: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 280),
            painter: HeaderPainter(color: Theme.of(context).primaryColor),
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
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Contact Support',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need Help?',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'If you have any questions, encounter issues, or need to request manual data deletion, our support team is ready to assist you. Tap below to contact us.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...emails.map((email) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 0,
                              color: isDark
                                  ? const Color(0xFF1E1B24)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white.withAlpha(20)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF4F378A,
                                    ).withAlpha(20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF4F378A),
                                  ),
                                ),
                                title: Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.copy_rounded,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: email));
                                  showToast('Email copied to clipboard!');
                                },
                              ),
                            );
                          }),

                          Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 0,
                            color: isDark
                                ? const Color(0xFF1E1B24)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.white.withAlpha(20)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF25D366).withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Color(0xFF25D366),
                                ),
                              ),
                              title: Text(
                                'Chat on WhatsApp',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              trailing: Icon(
                                Icons.open_in_new_rounded,
                                size: 20,
                                color: isDark ? Colors.white60 : Colors.grey,
                              ),
                              onTap: launchWhatsApp,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F378A).withAlpha(15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF4F378A).withAlpha(30),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFF4F378A),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Manual account or data deletion requests will be completed within 48 hours of receipt.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: Text(
                              '© 2026 Onyx App. All rights reserved.',
                              style: TextStyle(
                                fontSize: 12,
                                color: subtitleColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
