import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const PrivacyPolicyPage());

  const PrivacyPolicyPage({super.key});

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
                            'Privacy Policy',
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
                            'Onyx Privacy Policy',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Effective Date: July 17, 2026',
                            style: TextStyle(
                              fontSize: 14,
                              color: subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                           _buildSection(
                            context: context,
                            title: 'Welcome',
                            content:
                                'Welcome to Onyx ("we," "our," or "us"). We are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application, Onyx (the "App").',
                            textColor: textColor,
                          ),
                          _buildSection(
                            context: context,
                            title: '1. Information We Collect',
                            content:
                                'To provide you with our expense tracking and financial analysis features, we collect the following types of information:\n\n• Account Information: When you register via email or use Google/Facebook Social Logins, we collect your name, email address, profile picture (if provided), and unique user identifier.\n• Financial Records: Transaction details, logs, expense amounts, categories, dates, and connected wallet names.',
                            textColor: textColor,
                          ),
                          _buildHighlightBox(
                            context: context,
                            title: 'SMS Scanning & Data Usage',
                            content:
                                'Onyx includes an optional feature that scans transactional SMS alerts (such as debit/credit alerts from bank accounts) locally on your device to parse transaction values and auto-detect your expenses. We do NOT read your personal messages, and your raw SMS texts are NEVER sent to our servers. Only the parsed transaction details (amount, category, and date) are stored securely in your private cloud account.',
                          ),
                          _buildSection(
                            context: context,
                            title: '2. Artificial Intelligence (AI) Features',
                            content:
                                'Onyx incorporates advanced Artificial Intelligence features to analyze your spending history and provide customized budgeting advice, expense forecasts, and personalized financial feedback.\n\n• Data Processing for AI: Our AI algorithms process your logged transactional data (amounts, categories, and timestamps) to generate insights.\n• Privacy Safeguards: Your personal data is never shared with third parties to train public AI models. All insights are generated dynamically and securely within our encrypted database environment.',
                            textColor: textColor,
                          ),
                          _buildSection(
                            context: context,
                            title: '3. How We Use Your Information',
                            content:
                                'The information we collect is utilized to:\n• Create and secure your user profile.\n• Track and organize your personal cash flow, budgets, and wallets.\n• Analyze spending behaviors to generate automated AI feedback and suggestions.\n• Sync your data across devices securely via our Supabase database.',
                            textColor: textColor,
                          ),
                          _buildSection(
                            context: context,
                            title: '4. Third-Party Integrations',
                            content:
                                'Onyx connects to standard social authentication providers:\n• Google Sign-In: Covered by Google\'s Privacy Policy.\n• Facebook Login (Meta): Covered by Meta\'s Data Policy.',
                            textColor: textColor,
                          ),
                          _buildSection(
                            context: context,
                            title: '5. Your Data Rights & Deletion',
                            content:
                                'You have full ownership of your data. You can edit or purge your financial data inside the App, or request a complete account and data removal at any time. For steps on how to do this, please view our User Data Deletion Instructions.',
                            textColor: textColor,
                          ),
                          _buildSection(
                            context: context,
                            title: '6. Contact Us',
                            content:
                                'For any questions or requests regarding this privacy policy or your data rights, please contact us at:\n• hamim.leon@gmail.com\n• hamim15-5264@diu.edu.bd',
                            textColor: textColor,
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

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 14, height: 1.5, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBox({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : const Color(0xFFF5F2FD),
        border: Border(
          left: BorderSide(color: theme.primaryColor, width: 4),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
