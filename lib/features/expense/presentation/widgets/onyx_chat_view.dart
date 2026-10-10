import 'package:flutter/material.dart';
import 'package:expense_tracker/core/common/utils/onyx_nlp_chat_engine.dart';
import 'package:expense_tracker/core/common/utils/sound_service.dart';
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
    'Can I afford to spend 15000?',
    'How much on Food this month?',
    'Summarize my spending',
    'What are my subscriptions?',
    'What is my wallet balance?',
    'How can I save more?',
    'What is my biggest expense?',
    'This week vs last week',
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
