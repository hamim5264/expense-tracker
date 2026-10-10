import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/app_config.dart';
import 'package:expense_tracker/core/common/utils/onyx_nlp_chat_engine.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';

class OnyxLlmService {
  static const String _prefApiKey = 'openrouter_api_key';
  static const String _openRouterEndpoint = 'https://openrouter.ai/api/v1/chat/completions';

  // Free models available on OpenRouter (openrouter/free dynamically routes to available free models)
  static const List<String> freeModels = [
    'openrouter/free',
    'google/gemini-2.0-flash-exp:free',
    'meta-llama/llama-3.3-70b-instruct:free',
    'qwen/qwen-2.5-72b-instruct:free',
    'mistralai/mistral-small-24b-instruct-2501:free',
    'google/gemma-4-31b-it:free',
  ];

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 25),
      headers: {
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://hamim5264.github.io/onyx-policy',
        'X-Title': 'Onyx Nova Financial Advisor',
      },
    ),
  );

  static final OnyxLlmService instance = OnyxLlmService._internal();
  OnyxLlmService._internal();

  /// Retrieve the active OpenRouter API key (custom saved or .env)
  Future<String> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final custom = prefs.getString(_prefApiKey);
      if (custom != null && custom.trim().isNotEmpty) {
        return custom.trim();
      }
    } catch (_) {}

    return AppConfig.openRouterApiKey.trim();
  }

  /// Save a user-defined OpenRouter API key
  Future<void> setApiKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (key.trim().isEmpty) {
        await prefs.remove(_prefApiKey);
      } else {
        await prefs.setString(_prefApiKey, key.trim());
      }
    } catch (_) {}
  }

  /// Generate intelligent AI response using Free LLMs with on-device NLP fallback
  Future<OnyxChatMessage> askOnyx({
    required String query,
    required List<Expense> expenses,
    required List<Wallet> wallets,
    required String currencySymbol,
    List<OnyxChatMessage> conversationHistory = const [],
  }) async {
    final apiKey = await getApiKey();

    // If no API key configured, use on-device NLP engine directly
    if (apiKey.isEmpty) {
      debugPrint('ℹ️ No OpenRouter API key found. Using on-device OnyxNlpChatEngine.');
      return OnyxNlpChatEngine.processUserMessage(
        query: query,
        expenses: expenses,
        wallets: wallets,
        currencySymbol: currencySymbol,
      );
    }

    // Build rich financial context
    final systemPrompt = _buildFinancialContext(
      expenses: expenses,
      wallets: wallets,
      currencySymbol: currencySymbol,
    );

    // Build message list (system prompt + recent context + user query)
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    // Add recent conversational context (up to last 6 messages)
    final recentHistory = conversationHistory.length > 6
        ? conversationHistory.sublist(conversationHistory.length - 6)
        : conversationHistory;

    for (final msg in recentHistory) {
      if (msg.id == 'welcome') continue;
      messages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      });
    }

    messages.add({'role': 'user', 'content': query});

    bool hitRateLimit = false;

    // Try primary and fallback free models
    for (final model in freeModels) {
      try {
        debugPrint('🤖 Requesting Onyx Nova AI via model: $model');

        final response = await _dio.post(
          _openRouterEndpoint,
          options: Options(
            headers: {'Authorization': 'Bearer $apiKey'},
          ),
          data: jsonEncode({
            'model': model,
            'messages': messages,
            'temperature': 0.6,
            'max_tokens': 900,
          }),
        );

        if (response.statusCode == 200 && response.data != null) {
          final choices = response.data['choices'] as List?;
          if (choices != null && choices.isNotEmpty) {
            final content = choices[0]['message']?['content']?.toString().trim();
            if (content != null && content.isNotEmpty) {
              return OnyxChatMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                text: content,
                isUser: false,
                timestamp: DateTime.now(),
                type: 'text',
                extraData: {'model': model, 'provider': 'openrouter'},
              );
            }
          }
        }
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final responseBody = e.response?.data?.toString().toLowerCase() ?? '';
        debugPrint('⚠️ Model $model failed (HTTP $statusCode): ${e.message}');

        if (statusCode == 429 ||
            statusCode == 402 ||
            responseBody.contains('rate limit') ||
            responseBody.contains('quota') ||
            responseBody.contains('credits') ||
            responseBody.contains('too many requests')) {
          hitRateLimit = true;
        }
      } catch (e) {
        debugPrint('⚠️ Model $model unexpected error: $e');
      }
    }

    // Fallback to on-device engine
    debugPrint('🔄 LLM cloud unavailable. Seamlessly activating Onyx on-device core.');
    final localResult = OnyxNlpChatEngine.processUserMessage(
      query: query,
      expenses: expenses,
      wallets: wallets,
      currencySymbol: currencySymbol,
    );

    // If rate limit was encountered, format a formal, polite notification
    if (hitRateLimit) {
      final formalNotice =
          "⏳ **Notice: Neural Service Quota Exceeded**\n\n"
          "Our cloud neural model is currently experiencing peak traffic on the free tier limit.\n\n"
          "✨ **Onyx Nova On-Device Intelligence** has seamlessly stepped in to answer your query right away:\n\n"
          "---\n\n"
          "${localResult.text}\n\n"
          "💡 *Pro-tip: Rate limits reset within 60 seconds. You can also tap the three dots above to link your own free OpenRouter key for uninterrupted access!*";

      return OnyxChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: formalNotice,
        isUser: false,
        timestamp: DateTime.now(),
        type: localResult.type,
        affordability: localResult.affordability,
        extraData: {
          'rateLimited': true,
          'provider': 'ondevice_guard',
          if (localResult.extraData != null) ...localResult.extraData!,
        },
      );
    }

    return localResult;
  }

  /// Constructs the financial knowledge prompt injected into the AI
  String _buildFinancialContext({
    required List<Expense> expenses,
    required List<Wallet> wallets,
    required String currencySymbol,
  }) {
    final now = DateTime.now();

    // Current month filter
    final currentMonthExpenses = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();

    final totalIncome = currentMonthExpenses
        .where((e) => e.type.toLowerCase() == 'income')
        .fold(0.0, (sum, e) => sum + e.amount);

    final totalExpense = currentMonthExpenses
        .where((e) => e.type.toLowerCase() == 'expense')
        .fold(0.0, (sum, e) => sum + e.amount);

    final netSavings = totalIncome - totalExpense;
    final savingsRate = totalIncome > 0 ? ((netSavings / totalIncome) * 100) : 0.0;

    // Liquid balances across wallets
    final totalWalletBalance = wallets.fold(0.0, (sum, w) => sum + w.balance);
    final walletSummary = wallets.isEmpty
        ? 'No connected accounts created yet'
        : wallets
            .map((w) => '${w.name}: $currencySymbol${w.balance.toStringAsFixed(2)}')
            .join(', ');

    // Category breakdown
    final categoryTotals = <String, double>{};
    for (final exp in currentMonthExpenses.where((e) => e.type.toLowerCase() == 'expense')) {
      categoryTotals[exp.category] = (categoryTotals[exp.category] ?? 0.0) + exp.amount;
    }

    final topCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategoriesStr = topCategories.take(5).map((e) {
      final pct = totalExpense > 0 ? ((e.value / totalExpense) * 100).toStringAsFixed(1) : '0';
      return '${e.key}: $currencySymbol${e.value.toStringAsFixed(2)} ($pct%)';
    }).join('\n- ');

    // Recent transactions log (last 6 transactions)
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentTransactions = sortedExpenses.take(6).map((e) {
      final dateStr =
          '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
      return '$dateStr | ${e.type.toUpperCase()}: ${e.title} ($currencySymbol${e.amount.toStringAsFixed(2)}, Category: ${e.category})';
    }).join('\n- ');

    return '''
You are Onyx Nova AI, an exceptionally smart, warm, cute, and professional personal financial advisor integrated into the Onyx Expense Tracker app.

User's Live Financial Overview:
- Currency: $currencySymbol
- Total Liquid Net Worth across accounts: $currencySymbol${totalWalletBalance.toStringAsFixed(2)}
- Connected Accounts: $walletSummary
- Total Monthly Income (${now.year}-${now.month}): $currencySymbol${totalIncome.toStringAsFixed(2)}
- Total Monthly Expenses: $currencySymbol${totalExpense.toStringAsFixed(2)}
- Net Monthly Savings: $currencySymbol${netSavings.toStringAsFixed(2)}
- Current Savings Rate: ${savingsRate.toStringAsFixed(1)}%
- Top Spending Categories this month:
${topCategories.isEmpty ? 'No expenses logged yet this month.' : '- $topCategoriesStr'}

Recent Transactions Log:
${sortedExpenses.isEmpty ? 'No recent transactions logged.' : '- $recentTransactions'}

Your Quality & Behavior Guidelines:
1. Tone: Friendly, encouraging, polite, concise, and ultra-accurate.
2. Direct Answers First: Immediately answer the user's specific query using their real numbers above.
3. Affordability Inquiries (e.g., "Can I afford X?"):
   - Compare the amount to their liquid net worth and remaining monthly surplus.
   - Give a clear verdict (e.g., "Yes, easily affordable", "Careful / Proceed with caution", or "Not recommended right now").
   - Follow with a concise, actionable rationale.
4. Clean Formatting: Keep responses easy to scan on mobile screens. Use bullet points (•), bold numbers, and emojis for key insights. Avoid overly long paragraphs.
5. Multilingual Fluency: If the user writes in Bengali, Spanish, French, or any other language, answer fluently in that language while preserving number accuracy.
6. Absolute Consistency: Never invent numbers that contradict the provided financial overview.
''';
  }
}
