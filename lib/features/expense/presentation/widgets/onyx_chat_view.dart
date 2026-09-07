import 'package:expense_tracker/core/common/utils/onyx_nlp_chat_engine.dart';
import 'package:expense_tracker/core/common/utils/sound_service.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    // Initial friendly greeting
    _messages.add(
      OnyxChatMessage(
        id: 'welcome',
        text:
            "👋 Hi! I am Onyx AI, your personal financial advisor.\n\n"
            "Ask me anything about your money, balances, or whether you can afford an upcoming purchase. Tap any suggestion below or type your own question.",
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

  void _sendMessage(String text) {
    final query = text.trim();
    if (query.isEmpty) return;

    final userMsg = OnyxChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _textController.clear();
    });

    SoundService.playSuccess();
    _scrollToBottom();

    // Process with on-device NLP engine
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final botReply = OnyxNlpChatEngine.processUserMessage(
        query: query,
        expenses: widget.expenses,
        wallets: widget.wallets,
        currencySymbol: widget.currencySymbol,
      );

      setState(() {
        _messages.add(botReply);
      });
      _scrollToBottom();
    });
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

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark ? const Color(0xFF1E1B29) : Colors.white;
    final borderColor = widget.isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.shade200;

    return Column(
      children: [
        // Quick Action Chips
        Container(
          height: 44,
          margin: const EdgeInsets.only(top: 8, bottom: 6),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _quickChips.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final chip = _quickChips[idx];
              return ActionChip(
                backgroundColor: cardBg,
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                label: Text(
                  chip,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: widget.isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                onPressed: () => _sendMessage(chip),
              );
            },
          ),
        ),

        // Chat Message List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return _buildMessageItem(msg, cardBg, borderColor);
            },
          ),
        ),

        // Input Field Bar - Single clean floating pill container
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            MediaQuery.of(context).padding.bottom + 10,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isDark ? 0.25 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _sendMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask Onyx about your finances...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: widget.isDark ? Colors.white38 : Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: widget.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => _sendMessage(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(
    OnyxChatMessage msg,
    Color cardBg,
    Color borderColor,
  ) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Onyx Bot Response
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: widget.primaryColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Icon(
                CupertinoIcons.sparkles,
                size: 16,
                color: widget.primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                          color: Colors.black
                              .withOpacity(widget.isDark ? 0.2 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _formatMarkdownText(msg.text),
                  ),
                  if (msg.type == 'affordability' &&
                      msg.affordability != null) ...[
                    const SizedBox(height: 8),
                    _buildAffordabilityCard(
                      msg.affordability!,
                      cardBg,
                      borderColor,
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

  Widget _buildAffordabilityCard(
    OnyxAffordabilityResult aff,
    Color cardBg,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: aff.verdictColor.withOpacity(widget.isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: aff.verdictColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                aff.itemName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: aff.verdictColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  aff.verdict,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: aff.verdictColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Price: ',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
              Text(
                '${widget.currencySymbol}${aff.itemAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                'Buffer Left: ',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
              Text(
                '${widget.currencySymbol}${aff.bufferAfterPurchase.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: aff.bufferAfterPurchase >= 0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            aff.reasoning,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.35,
              color: widget.isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formatMarkdownText(String text) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) => _renderLine(line)).toList(),
    );
  }

  Widget _renderLine(String rawLine) {
    // Remove all asterisks completely as requested
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
            color: widget.isDark
                ? Colors.white.withOpacity(0.9)
                : Colors.black87,
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
          color:
              widget.isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
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
