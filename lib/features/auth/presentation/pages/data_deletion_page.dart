import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:flutter/material.dart';

class DataDeletionPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const DataDeletionPage());

  const DataDeletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.scaffoldBackgroundColor : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: cardColor,
      body: Stack(
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
                            'Data Deletion',
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
                            'Onyx Data Deletion Instructions',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Last Updated: July 17, 2026',
                            style: TextStyle(
                              fontSize: 14,
                              color: subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'At Onyx, we value your privacy and control over your personal data. According to Meta (Facebook) and Google Play Platform rules, you have the right to request the deletion of your account and any associated data synced from third-party social integrations (like Facebook Login).',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildStepBox(
                            context: context,
                            title:
                                'Method 1: In-App Account Deletion (Recommended)',
                            steps: [
                              'Open the Onyx app.',
                              'Go to the Profile tab (person icon in the bottom menu).',
                              'Select Login and security (or Data and privacy).',
                              'Tap Delete Account and confirm the deletion.',
                            ],
                            note:
                                'This will instantly and permanently delete your profile, transaction logs, and wallet configurations from our database.',
                          ),
                          const SizedBox(height: 12),
                          _buildStepBox(
                            context: context,
                            title: 'Method 2: Email Data Deletion Request',
                            steps: [
                              'Send an email to our support team.',
                              'Use Subject: Onyx Data Deletion Request',
                              'Provide your registered email address or social identifier in the email body.',
                            ],
                            note:
                                'Upon receiving your request, we will permanently purge all profile information, social tokens, transactional logs, and configuration settings from our servers within 48 hours.',
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'What Data is Deleted?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4F378A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'When you request account deletion, the following data is permanently destroyed from our database:\n• Your account profile (Name, email address, avatar photo).\n• All logged income, expenses, and budget settings.\n• Connected wallet structures.\n• Saved security credentials.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 24),
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

  Widget _buildStepBox({
    required BuildContext context,
    required String title,
    required List<String> steps,
    required String note,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : const Color(0xFFF5F2FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4F378A).withAlpha(40),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4F378A),
            ),
          ),
          const SizedBox(height: 10),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final text = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$index. ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F378A),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '*Note: $note',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
