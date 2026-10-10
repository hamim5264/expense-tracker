import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:expense_tracker/core/common/utils/onyx_nlp_chat_engine.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/onyx_affordability_card.dart';

class OnyxChatBubble extends StatelessWidget {
  final OnyxChatMessage message;
  final bool isDark;
  final Color primaryColor;
  final String currencySymbol;

  const OnyxChatBubble({
    super.key,
    required this.message,
    required this.isDark,
    required this.primaryColor,
    required this.currencySymbol,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.text));
    Fluttertoast.showToast(
      msg: 'Message copied to clipboard',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E1B29) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.shade200;

    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: primaryColor.computeLuminance() > 0.45
                  ? Colors.black.withOpacity(0.12)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: primaryColor.computeLuminance() > 0.45
                  ? Colors.black87
                  : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Bot Response Bubble
    final isLlmResponse = message.extraData != null &&
        message.extraData!['provider'] == 'openrouter';
    final isRateLimited = message.extraData != null &&
        message.extraData!['rateLimited'] == true;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.16),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Lottie.asset(
                  'assets/animations/onyx_ai.json',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      CupertinoIcons.sparkles,
                      size: 18,
                      color: primaryColor,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onLongPress: () => _copyToClipboard(context),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormattedText(message.text),
                          if (isRateLimited) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.amber.withOpacity(0.35),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.shield_lefthalf_fill,
                                        size: 10,
                                        color: Colors.amber,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Rate Limit Guard Active',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ] else if (isLlmResponse) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: primaryColor.withOpacity(0.25),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.bolt_fill,
                                        size: 10,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Onyx Nova Neural AI',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (message.type == 'affordability' &&
                      message.affordability != null) ...[
                    const SizedBox(height: 8),
                    OnyxAffordabilityCard(
                      affordability: message.affordability!,
                      currencySymbol: currencySymbol,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) => _renderLine(line)).toList(),
    );
  }

  Widget _renderLine(String rawLine) {
    final line = rawLine.replaceAll('*', '').trimRight();
    if (line.isEmpty) return const SizedBox(height: 6);

    final trimmed = line.trimLeft();
    final isBullet = trimmed.startsWith('•') || trimmed.startsWith('-');
    final content = isBullet ? trimmed.substring(1).trim() : line;

    Widget textWidget;
    if (content.contains(': ') && !content.startsWith('http')) {
      final idx = content.indexOf(': ');
      final title = content.substring(0, idx + 1);
      final value = content.substring(idx + 1);
      textWidget = RichText(
        text: TextSpan(
          style: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
            fontSize: 13,
            height: 1.45,
          ),
          children: [
            TextSpan(
              text: title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      );
    } else {
      textWidget = Text(
        content,
        style: TextStyle(
          color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
          fontSize: 13,
          height: 1.45,
        ),
      );
    }

    if (isBullet) {
      return Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 4, top: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6, right: 8),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF0284C7),
                shape: BoxShape.circle,
              ),
            ),
            Expanded(child: textWidget),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: textWidget,
    );
  }
}
