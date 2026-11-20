import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_tracker/core/common/utils/onyx_nlp_chat_engine.dart';
import 'package:expense_tracker/core/common/utils/sound_service.dart';
import 'package:expense_tracker/core/services/ad_service.dart';
import 'package:expense_tracker/core/services/onyx_ai_credits_service.dart';
import 'package:expense_tracker/core/services/onyx_llm_service.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/onyx_chat_bubble.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/onyx_chat_input_bar.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/onyx_quick_chips.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/onyx_typing_indicator.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/onyx_ai_key_dialog.dart';

class OnyxChatView extends StatefulWidget {
  final List<Expense> expenses;
  final List<Wallet> wallets;
  final String currencySymbol;
  final bool isDark;
  final Color primaryColor;

  const OnyxChatView({
    super.key,
    required this.expenses,
    required this.wallets,
    required this.currencySymbol,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  State<OnyxChatView> createState() => _OnyxChatViewState();
}

class _OnyxChatViewState extends State<OnyxChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<OnyxChatMessage> _messages = [];
  bool _isLoading = false;

  final List<String> _quickChips = [
    'Can I afford 15k?',
    'Food spend',
    'Summarize',
    'Subscriptions',
    'Wallet balance',
    'Save more tips',
    'Top expenses',
    'Weekly comparison',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      OnyxChatMessage(
        id: 'welcome',
        text: "👋 Hi! I am Onyx Nova, your personal financial advisor powered by neural intelligence.\n\n"
            "Ask me anything about your budget, savings goals, or whether you can afford an upcoming purchase.",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || _isLoading) return;

    // Check if user has AI chat credits
    if (!OnyxAiCreditsService.hasCredits) {
      _showUnlockMessagesSheet(pendingText: query);
      return;
    }

    // Deduct 1 credit for sending this message
    await OnyxAiCreditsService.consumeCredit();
    await _executeSend(query);
  }

  Future<void> _executeSend(String query) async {
    final userMsg = OnyxChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
      _textController.clear();
    });

    // Tactile feedback on user message send
    SoundService.playTap();
    _scrollToBottom();

    try {
      // 3x More Powerful: OpenRouter Free Models with rate-limit protection & on-device fallback
      final botReply = await OnyxLlmService.instance.askOnyx(
        query: query,
        expenses: widget.expenses,
        wallets: widget.wallets,
        currencySymbol: widget.currencySymbol,
        conversationHistory: _messages,
      );

      if (mounted) {
        setState(() {
          _messages.add(botReply);
          _isLoading = false;
        });
        // Perfectly synchronized sound when AI reply arrives
        SoundService.playSuccess();
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        // Safe on-device fallback
        final fallback = OnyxNlpChatEngine.processUserMessage(
          query: query,
          expenses: widget.expenses,
          wallets: widget.wallets,
          currencySymbol: widget.currencySymbol,
        );
        setState(() {
          _messages.add(fallback);
          _isLoading = false;
        });
        // Synced sound on fallback arrival
        SoundService.playSuccess();
        _scrollToBottom();
      }
    }
  }

  void _showUnlockMessagesSheet({String? pendingText}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetCtx) {
        return _OnyxAdUnlockSheet(
          isDark: widget.isDark,
          primaryColor: widget.primaryColor,
          onAdSuccess: () async {
            Navigator.pop(bottomSheetCtx);
            await OnyxAiCreditsService.addCredits(3);
            if (pendingText != null && pendingText.isNotEmpty) {
              await OnyxAiCreditsService.consumeCredit();
              _executeSend(pendingText);
              Fluttertoast.showToast(
                msg: '🎉 +3 Messages unlocked! (${OnyxAiCreditsService.credits} remaining)',
                toastLength: Toast.LENGTH_LONG,
              );
            } else {
              Fluttertoast.showToast(
                msg: '🎉 +3 AI chat messages added!',
                toastLength: Toast.LENGTH_LONG,
              );
            }
          },
        );
      },
    );
  }

  Widget _buildCreditsBadge(int credits) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: credits > 0
              ? widget.primaryColor.withOpacity(widget.isDark ? 0.16 : 0.08)
              : const Color(0xFFF59E0B).withOpacity(widget.isDark ? 0.18 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: credits > 0
                ? widget.primaryColor.withOpacity(0.3)
                : const Color(0xFFF59E0B).withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              credits > 0 ? CupertinoIcons.bolt_fill : CupertinoIcons.play_circle_fill,
              size: 15,
              color: credits > 0 ? widget.primaryColor : const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                credits > 0
                    ? '$credits AI Message${credits == 1 ? '' : 's'} Remaining'
                    : '0 Credits • Watch video to chat',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: credits > 0
                      ? (widget.isDark ? Colors.white : Colors.black87)
                      : const Color(0xFFF59E0B),
                ),
              ),
            ),
            InkWell(
              onTap: () => _showUnlockMessagesSheet(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.primaryColor,
                      widget.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.play_arrow_solid, size: 10, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      '+3 Free',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AI Credits Status Bar
        ValueListenableBuilder<int>(
          valueListenable: OnyxAiCreditsService.creditsNotifier,
          builder: (context, credits, _) {
            return _buildCreditsBadge(credits);
          },
        ),

        // Quick Action Chips Widget
        OnyxQuickChips(
          chips: _quickChips,
          isDark: widget.isDark,
          onChipSelected: _sendMessage,
        ),

        // Chat Messages List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) {
                return OnyxTypingIndicator(
                  primaryColor: widget.primaryColor,
                  isDark: widget.isDark,
                );
              }

              return OnyxChatBubble(
                message: _messages[index],
                isDark: widget.isDark,
                primaryColor: widget.primaryColor,
                currencySymbol: widget.currencySymbol,
              );
            },
          ),
        ),

        // Floating Modular Input Bar
        OnyxChatInputBar(
          controller: _textController,
          isDark: widget.isDark,
          primaryColor: widget.primaryColor,
          isLoading: _isLoading,
          onSubmitted: _sendMessage,
          onSettingsTap: () {
            OnyxAiKeyDialog.show(
              context,
              isDark: widget.isDark,
              primaryColor: widget.primaryColor,
            );
          },
        ),
      ],
    );
  }
}

class _OnyxAdUnlockSheet extends StatefulWidget {
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onAdSuccess;

  const _OnyxAdUnlockSheet({
    required this.isDark,
    required this.primaryColor,
    required this.onAdSuccess,
  });

  @override
  State<_OnyxAdUnlockSheet> createState() => _OnyxAdUnlockSheetState();
}

class _OnyxAdUnlockSheetState extends State<_OnyxAdUnlockSheet> {
  bool _isLoading = false;

  Future<void> _watchAd() async {
    setState(() => _isLoading = true);
    await AdService.showRewardedAdWithDialog(
      context: context,
      loadingMessage: 'Loading video ad...',
      onUserEarnedReward: () {
        if (mounted) {
          setState(() => _isLoading = false);
          widget.onAdSuccess();
        }
      },
      onFailedOrDismissed: () {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheetBg = widget.isDark ? const Color(0xFF1E1A2C) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF211B38);
    final subtitleColor =
        widget.isDark ? const Color(0xFFA69EB8) : const Color(0xFF756F86);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Glowing Icon
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  widget.primaryColor,
                  widget.primaryColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withOpacity(0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.play_circle_fill,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Unlock AI Chat Messages',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'Watch a short video ad to unlock 3 interactive AI messages with Onyx Nova Advisor.',
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Watch Ad Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _watchAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(CupertinoIcons.play_arrow_solid, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Watch Video (+3 Messages)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Maybe later button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: TextStyle(
                color: subtitleColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
