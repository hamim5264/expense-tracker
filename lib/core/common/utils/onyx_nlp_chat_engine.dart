import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:flutter/material.dart';

class OnyxAffordabilityResult {
  final String itemName;
  final double itemAmount;
  final double liquidBalance;
  final String verdict; // 'Safe Purchase', 'Proceed with Caution', 'High Risk / Delay'
  final Color verdictColor;
  final double bufferAfterPurchase;
  final double currentSavingsRate;
  final double projectedSavingsRate;
  final String reasoning;

  OnyxAffordabilityResult({
    required this.itemName,
    required this.itemAmount,
    required this.liquidBalance,
    required this.verdict,
    required this.verdictColor,
    required this.bufferAfterPurchase,
    required this.currentSavingsRate,
    required this.projectedSavingsRate,
    required this.reasoning,
  });
}

class OnyxChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String type; // 'text', 'affordability', 'category_breakdown', 'summary'
  final OnyxAffordabilityResult? affordability;
  final Map<String, dynamic>? extraData;

  OnyxChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type = 'text',
    this.affordability,
    this.extraData,
  });
}

class OnyxNlpChatEngine {
  static OnyxChatMessage processUserMessage({
    required String query,
    required List<Expense> expenses,
    required List<Wallet> wallets,
    required String currencySymbol,
  }) {
    final cleanQuery = query.replaceAll(RegExp(r'[?!.,]'), ' ').trim();
    final lower = cleanQuery.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    // 1. Identity / Name Query
    if (lower.contains('your name') ||
        lower.contains('ur name') ||
        lower.contains('who are you') ||
        lower.contains('who r u') ||
        lower.contains('what are you') ||
        lower.contains('introduce yourself') ||
        lower == 'whats your name' ||
        lower == "what's your name" ||
        lower == 'what is your name' ||
        lower == 'name') {
      return _handleIdentityQuery();
    }

    // 2. Irrelevant / Non-Financial Query Check
    if (_isIrrelevantQuery(lower)) {
      return _handleIrrelevantQuery(query);
    }

    // 3. Greetings & Help
    if (lower == 'hi' ||
        lower == 'hello' ||
        lower == 'hey' ||
        lower.contains('good morning') ||
        lower.contains('good afternoon') ||
        lower.contains('good evening') ||
        lower.contains('what can you do') ||
        lower.contains('help')) {
      return _handleGreeting();
    }

    // 4. Affordability Check
    if (_isAffordabilityQuery(lower)) {
      return _handleAffordability(lower, expenses, wallets, currencySymbol);
    }

    // 5. Category Spending Query (Whole-word matching)
    final matchedCategory = _detectCategory(lower);
    if (matchedCategory != null) {
      return _handleCategorySpend(
        matchedCategory,
        expenses,
        currencySymbol,
      );
    }

    // 6. Subscriptions / Recurring
    if (lower.contains('subscript') || lower.contains('recurring')) {
      return _handleSubscriptions(expenses, currencySymbol);
    }

    // 7. Highest / Top Spending
    if (lower.contains('biggest') ||
        lower.contains('largest') ||
        lower.contains('top spend') ||
        lower.contains('top expense') ||
        lower.contains('most money')) {
      return _handleTopExpense(expenses, currencySymbol);
    }

    // 8. Summary / Status
    if (lower.contains('summary') ||
        lower.contains('report') ||
        lower.contains('how am i doing') ||
        lower.contains('financial status') ||
        lower.contains('overview')) {
      return _handleMonthlySummary(expenses, wallets, currencySymbol);
    }

    // 9. Weekly Trends
    if (lower.contains('this week') ||
        lower.contains('last week') ||
        lower.contains('weekly')) {
      return _handleWeeklyTrend(expenses, currencySymbol);
    }

    // 10. Total Balance / Wallets
    if (lower.contains('balance') ||
        lower.contains('wallet') ||
        lower.contains('cards') ||
        lower.contains('cash in hand') ||
        lower.contains('net worth') ||
        lower.contains('how much money do i have')) {
      return _handleWalletBalances(wallets, currencySymbol);
    }

    // 11. Saving Tips & Advice
    if (lower.contains('save') ||
        lower.contains('tip') ||
        lower.contains('advice') ||
        lower.contains('cut expense') ||
        lower.contains('cut cost') ||
        lower.contains('reduce')) {
      return _handleSavingAdvice(expenses, currencySymbol);
    }

    // 12. Fallback with formal guidance
    return _handleFallback(expenses, currencySymbol);
  }

  // --- Irrelevant & Identity Handlers ---

  static bool _isIrrelevantQuery(String query) {
    const nonFinancialKeywords = [
      'weather',
      'forecast',
      'temperature',
      'rain',
      'raining',
      'sunny',
      'climate',
      'cloud',
      'storm',
      'snow',
      'wind',
      'windy',
      'degree',
      'celsius',
      'fahrenheit',
      'president',
      'politics',
      'election',
      'minister',
      'parliament',
      'government',
      'war',
      'news',
      'joke',
      'funny',
      'humor',
      'poem',
      'song',
      'music',
      'sing',
      'lyrics',
      'recipe',
      'cook',
      'cooking',
      'ingredient',
      'bake',
      'football',
      'soccer',
      'cricket',
      'sports',
      'messi',
      'ronaldo',
      'match',
      'game',
      'gaming',
      'pubg',
      'fifa',
      'code',
      'coding',
      'programming',
      'python',
      'flutter',
      'dart',
      'javascript',
      'debug',
      'compile',
      'movie',
      'movies',
      'film',
      'actor',
      'actress',
      'cinema',
      'hollywood',
      'bollywood',
      'anime',
      'homework',
      'translate',
      'translation',
      'meaning of life',
    ];

    for (final kw in nonFinancialKeywords) {
      if (RegExp('\\b${RegExp.escape(kw)}\\b').hasMatch(query)) {
        return true;
      }
    }

    const conversationalPhrases = [
      'how are you',
      'how r you',
      'how r u',
      'how do you do',
      'what are you doing',
      'are you real',
      'are you human',
      'are you ai',
      'are you an ai',
      'who made you',
      'who created you',
      'who developed you',
      'where do you live',
      'where are you',
      'how old are you',
      'what is your age',
      'what is love',
      'tell me a joke',
      'tell me a story',
      'tell me something',
      'make me laugh',
      'what is the time',
      'what time is it',
      'who is ',
      'how to ',
      'what is the meaning',
    ];

    for (final phrase in conversationalPhrases) {
      if (query.contains(phrase)) {
        return true;
      }
    }

    // Short casual fillers that are not financial
    const fillerWords = [
      'ok',
      'okay',
      'cool',
      'nice',
      'great',
      'awesome',
      'good',
      'fine',
      'thanks',
      'thank you',
      'thx',
      'bye',
      'goodbye',
      'see you',
      'lol',
      'haha',
      'hehe',
      'asdf',
      'test',
    ];

    if (fillerWords.contains(query)) {
      return true;
    }

    return false;
  }

  static OnyxChatMessage _handleIrrelevantQuery(String query) {
    return OnyxChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "I am Onyx AI, an intelligent advisor dedicated exclusively to your personal finances and budget management.\n\n"
          "I am unable to assist with non-financial topics or external inquiries.\n\n"
          "You may ask me questions such as:\n"
          "• Can I afford to spend ৳15,000?\n"
          "• How much did I spend on Food this month?\n"
          "• Summarize my spending and savings\n"
          "• What is my total balance across wallets?\n\n"
          "Please ask any question regarding your transactions, wallets, or upcoming purchases.",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  static OnyxChatMessage _handleIdentityQuery() {
    return OnyxChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "I am Onyx AI, your personal financial advisor built into the Onyx Expense Tracker.\n\n"
          "My purpose is to help you track expenses, analyze spending habits, evaluate purchase affordability, and maintain strong financial health.",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  // --- Affordability Detection & Handler ---

  static bool _isAffordabilityQuery(String query) {
    return query.contains('afford') ||
        query.contains('can i buy') ||
        query.contains('can i spend') ||
        query.contains('should i buy') ||
        query.contains('can i get') ||
        query.contains('can i purchase');
  }

  static OnyxChatMessage _handleAffordability(
    String query,
    List<Expense> expenses,
    List<Wallet> wallets,
    String currencySymbol,
  ) {
    final amount = _extractAmount(query);
    final itemName = _extractItemName(query);

    if (amount == null || amount <= 0) {
      return OnyxChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            "I would be glad to calculate that for you. Please include the estimated price (for example: Can I afford to buy a laptop for 45000?).",
        isUser: false,
        timestamp: DateTime.now(),
      );
    }

    final totalWalletBalance =
        wallets.fold(0.0, (sum, item) => sum + item.balance);

    final totalIncome = expenses
        .where((e) => e.type == 'income')
        .fold(0.0, (sum, item) => sum + item.amount);

    final totalExpense = expenses
        .where((e) => e.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);

    final currentSavings = totalIncome - totalExpense;
    final currentSavingsRate =
        totalIncome > 0 ? (currentSavings / totalIncome) * 100 : 0.0;

    final bufferAfter = totalWalletBalance - amount;
    final projectedSavings = currentSavings - amount;
    final projectedSavingsRate =
        totalIncome > 0 ? (projectedSavings / totalIncome) * 100 : 0.0;

    String verdict;
    Color verdictColor;
    String reasoning;

    if (bufferAfter < 0) {
      verdict = 'High Risk / Delay';
      verdictColor = const Color(0xFFEF4444);
      reasoning =
          'This purchase would exceed your total liquid balance by $currencySymbol${bufferAfter.abs().toStringAsFixed(0)}. You would risk overdraft or debt.';
    } else if (bufferAfter < (totalWalletBalance * 0.25) ||
        projectedSavingsRate < 10) {
      verdict = 'Proceed with Caution';
      verdictColor = const Color(0xFFF59E0B);
      reasoning =
          'You have the cash, but it will consume a large portion of your liquid buffer and reduce your savings rate to ${projectedSavingsRate.toStringAsFixed(0)}%.';
    } else {
      verdict = 'Safe Purchase';
      verdictColor = const Color(0xFF10B981);
      reasoning =
          'You can safely afford this. You will still maintain a healthy liquid buffer of $currencySymbol${bufferAfter.toStringAsFixed(0)}.';
    }

    final result = OnyxAffordabilityResult(
      itemName: itemName,
      itemAmount: amount,
      liquidBalance: totalWalletBalance,
      verdict: verdict,
      verdictColor: verdictColor,
      bufferAfterPurchase: bufferAfter,
      currentSavingsRate: currentSavingsRate,
      projectedSavingsRate: projectedSavingsRate,
      reasoning: reasoning,
    );

    return OnyxChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Here is my financial affordability assessment for $itemName:",
      isUser: false,
      timestamp: DateTime.now(),
      type: 'affordability',
      affordability: result,
    );
  }

  static double? _extractAmount(String text) {
    // Check for '15k' or '15.5k'
    final kMatch = RegExp(r'(\d+(?:\.\d+)?)\s*k\b').firstMatch(text);
    if (kMatch != null) {
      final val = double.tryParse(kMatch.group(1)!);
      if (val != null) return val * 1000;
    }

    // Check standard numbers with optional currency symbols or commas
    final matches = RegExp(r'(?:[\$৳€£₹¥]?\s*)(\d+(?:,\d+)*(?:\.\d+)?)')
        .allMatches(text);
    for (final match in matches) {
      final raw = match.group(1)!.replaceAll(',', '');
      final parsed = double.tryParse(raw);
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }
    return null;
  }

  static String _extractItemName(String query) {
    final clean = query
        .replaceAll(RegExp(r'\b(can i|should i|buy|purchase|afford|a|an|the|for|cost|price|spend|money|much)\b'), '')
        .replaceAll(RegExp(r'[\$৳€£₹¥]?\s*\d+(?:,\d+)*(?:\.\d+)?k?'), '')
        .replaceAll(RegExp(r'[?!.,]'), '')
        .trim();

    if (clean.length > 2 && clean.length < 30) {
      return clean
          .split(' ')
          .map((w) => w.isNotEmpty
              ? '${w[0].toUpperCase()}${w.substring(1)}'
              : '')
          .join(' ');
    }
    return 'This Purchase';
  }

  // --- Category Spend Handler (Strict Whole-Word Matching) ---

  static String? _detectCategory(String query) {
    final categoryKeywords = <String, List<String>>{
      'Food': [
        'food',
        'groceries',
        'grocery',
        'dining',
        'restaurant',
        'meal',
        'lunch',
        'dinner',
        'breakfast',
        'cafe',
        'snacks',
        'eat',
      ],
      'Transport': [
        'transport',
        'transportation',
        'uber',
        'taxi',
        'bus',
        'train',
        'fuel',
        'gas',
        'metro',
        'commute',
        'petrol',
      ],
      'Shopping': [
        'shopping',
        'clothes',
        'clothing',
        'apparel',
        'shoes',
        'mall',
        'electronics',
      ],
      'Entertainment': [
        'entertainment',
        'movies',
        'cinema',
        'netflix',
        'spotify',
        'games',
        'concert',
        'gaming',
      ],
      'Bills': [
        'bills',
        'utility',
        'electricity',
        'water bill',
        'gas bill',
        'internet',
        'wifi',
        'recharge',
        'mobile bill',
      ],
      'Health': [
        'health',
        'medical',
        'medicine',
        'doctor',
        'hospital',
        'pharmacy',
        'dental',
        'clinic',
      ],
      'Education': [
        'education',
        'tuition',
        'course',
        'school',
        'college',
        'university',
        'books',
        'exam fee',
      ],
      'Salary': ['salary', 'paycheck', 'wages'],
      'Freelance': ['freelance', 'upwork', 'fiverr', 'client payment'],
      'Investments': [
        'investment',
        'investments',
        'stocks',
        'crypto',
        'shares',
        'dividend',
      ],
      'Personal Care': ['personal care', 'salon', 'barber', 'spa', 'haircut'],
      'Travel': ['travel', 'flight', 'hotel', 'vacation', 'trip'],
      'Rent': ['rent', 'house rent', 'apartment'],
      'Others': ['others', 'miscellaneous'],
    };

    // Strict WHOLE WORD matching
    for (final entry in categoryKeywords.entries) {
      for (final kw in entry.value) {
        if (RegExp('\\b${RegExp.escape(kw)}\\b').hasMatch(query)) {
          return entry.key;
        }
      }
    }

    return null;
  }

  static OnyxChatMessage _handleCategorySpend(
    String category,
    List<Expense> expenses,
    String currencySymbol,
  ) {
    final matchedExpenses = expenses
        .where((e) =>
            e.type == 'expense' &&
            e.category.toLowerCase().contains(category.toLowerCase()))
        .toList();

    final totalCatSpend =
        matchedExpenses.fold(0.0, (sum, item) => sum + item.amount);
    final overallExpenses = expenses
        .where((e) => e.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);

    final catPercentage = overallExpenses > 0
        ? (totalCatSpend / overallExpenses) * 100
        : 0.0;

    final catTitle = category[0].toUpperCase() + category.substring(1);

    if (matchedExpenses.isEmpty) {
      return OnyxChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "You have not recorded any expenses under $catTitle yet.",
        isUser: false,
        timestamp: DateTime.now(),
      );
    }

    matchedExpenses.sort((a, b) => b.amount.compareTo(a.amount));
    final topTx = matchedExpenses.first;

    final text =
        "You have spent $currencySymbol${totalCatSpend.toStringAsFixed(2)} across ${matchedExpenses.length} transactions in $catTitle.\n\n"
        "• Portion of Total Expenses: ${catPercentage.toStringAsFixed(1)}%\n"
        "• Largest Transaction: \"${topTx.title}\" ($currencySymbol${topTx.amount.toStringAsFixed(2)})\n\n"
        "${catPercentage > 40 ? 'Notice: This category consumes more than 40% of your total budget. Consider setting a weekly limit.' : 'Status: Healthy spending level for this category.'}";

    return OnyxChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      type: 'category_breakdown',
    );
  }

  // --- Subscriptions Handler ---

  static OnyxChatMessage _handleSubscriptions(
    List<Expense> expenses,
    String currencySymbol,
  ) {
    final expenseMap = <String, List<Expense>>{};
    for (final exp in expenses.where((e) => e.type == 'expense')) {
      final key = '${exp.category}_${exp.amount.toStringAsFixed(2)}';
      expenseMap.putIfAbsent(key, () => []).add(exp);
    }

    final recurring = <String>[];
    double monthlyTotal = 0.0;
    expenseMap.forEach((key, list) {
      if (list.length >= 2) {
        final amount = list.first.amount;
        monthlyTotal += amount;
        recurring.add(
            "• ${list.first.title}: $currencySymbol${amount.toStringAsFixed(2)} (${list.first.category})");
      }
    });

    if (recurring.isEmpty) {
      return OnyxChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            "I have not detected recurring subscription patterns yet. As you record regular recurring expenses (such as streaming services, utilities, or gym memberships), I will automatically audit them for you.",
        isUser: false,
        timestamp: DateTime.now(),
      );
    }

    final annualCost = monthlyTotal * 12;
    return OnyxChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "Found ${recurring.length} recurring charges totaling $currencySymbol${monthlyTotal.toStringAsFixed(2)} per month:\n\n"
          "${recurring.join('\n')}\n\n"
          "Annual Cost Impact: Over the next 12 months, these will total $currencySymbol${annualCost.toStringAsFixed(0)}. Review them periodically to cancel unused subscriptions.",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  // --- Top Expense Handler ---

  static OnyxChatMessage _handleTopExpense(
    List<Expense> expenses,
    String currencySymbol,
  ) {
    final expenseList =
        expenses.where((e) => e.type == 'expense').toList();
    if (expenseList.isEmpty) {
      return OnyxChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            "No expenses recorded yet. Record a transaction to see your top spending.",
        isUser: false,
        timestamp: DateTime.now(),
      );
    }

    expenseList.sort((a, b) => b.amount.compareTo(a.amount));
    final top = expenseList.first;

    return OnyxChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "Your largest single transaction is \"${top.title}\" for $currencySymbol${top.amount.toStringAsFixed(2)} in ${top.category} on ${top.date.day}/${top.date.month}/${top.date.year}.",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  // --- Monthly Summary Handler ---

  static OnyxChatMessage _handleMonthlySummary(
    List<Expense> expenses,
    List<Wallet> wallets,
    String currencySymbol,
  ) {
    final totalIncome = expenses
        .where((e) => e.type == 'income')
        .fold(0.0, (sum, item) => sum + item.amount);

    final totalExpense = expenses
        .where((e) => e.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);

    final netSavings = totalIncome - totalExpense;
    final totalBalance =
        wallets.fold(0.0, (sum, item) => sum + item.balance);

    final savingsRate =
        totalIncome > 0 ? (netSavings / totalIncome) * 100 : 0.0;

    return OnyxChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "Executive Financial Summary:\n\n"
          "• Total Income: $currencySymbol${totalIncome.toStringAsFixed(2)}\n"
          "• Total Expenses: $currencySymbol${totalExpense.toStringAsFixed(2)}\n"
          "• Net Savings: $currencySymbol${netSavings.toStringAsFixed(2)} (${savingsRate.toStringAsFixed(1)}% savings rate)\n"
          "• Total Balance in Wallets: $currencySymbol${totalBalance.toStringAsFixed(2)}\n\n"
          "${netSavings >= 0 ? 'Status: You are living comfortably within your means.' : 'Warning: Your spending exceeds your income this period.'}",
      isUser: false,
      timestamp: DateTime.now(),
      type: 'summary',
    );
  }

  // --- Weekly Trend Handler ---

  static OnyxChatMessage _handleWeeklyTrend(
    List<Expense> expenses,
    String currencySymbol,
  ) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    final recent7Spend = expenses
        .where((e) => e.type == 'expense' && e.date.isAfter(sevenDaysAgo))
        .fold(0.0, (sum, item) => sum + item.amount);

    final prior7Spend = expenses
        .where((e) =>
            e.type == 'expense' &&
            e.date.isAfter(fourteenDaysAgo) &&
            e.date.isBefore(sevenDaysAgo))
        .fold(0.0, (sum, item) => sum + item.amount);

    String message;
    if (prior7Spend > 0) {
      final delta = ((recent7Spend - prior7Spend) / prior7Spend) * 100;
      if (delta > 15) {
        message =
            "Your 7-day spending ($currencySymbol${recent7Spend.toStringAsFixed(2)}) is ${delta.toStringAsFixed(1)}% higher than last week ($currencySymbol${prior7Spend.toStringAsFixed(2)}). Check recent transactions to monitor discretionary spending.";
      } else if (delta < -15) {
        message =
            "Good progress. You spent ${delta.abs().toStringAsFixed(1)}% less this week ($currencySymbol${recent7Spend.toStringAsFixed(2)}) compared to the prior 7 days ($currencySymbol${prior7Spend.toStringAsFixed(2)}).";
      } else {
        message =
            "Your spending is steady: $currencySymbol${recent7Spend.toStringAsFixed(2)} this week compared to $currencySymbol${prior7Spend.toStringAsFixed(2)} last week.";
      }
    } else {
      message =
          "In the last 7 days, you have spent $currencySymbol${recent7Spend.toStringAsFixed(2)}. Continue recording daily expenses for week-over-week comparisons.";
    }

    return OnyxChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  // --- Wallet Balances Handler ---

  static OnyxChatMessage _handleWalletBalances(
    List<Wallet> wallets,
    String currencySymbol,
  ) {
    if (wallets.isEmpty) {
      return OnyxChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            "You have not linked any wallets yet. You can add bank accounts, cards, or Cash in Hand in the Wallets tab.",
        isUser: false,
        timestamp: DateTime.now(),
      );
    }

    final total = wallets.fold(0.0, (sum, item) => sum + item.balance);
    final lines = wallets.map((w) {
      final cleanName = w.name.replaceAll('••', '').replaceAll('•', '').trim();
      return "• $cleanName: $currencySymbol${w.balance.toStringAsFixed(2)}";
    }).join('\n');

    return OnyxChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "Total Liquid Balance: $currencySymbol${total.toStringAsFixed(2)}\n\n"
          "Account Breakdown:\n$lines",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  // --- Saving Advice Handler ---

  static OnyxChatMessage _handleSavingAdvice(
    List<Expense> expenses,
    String currencySymbol,
  ) {
    final expenseList =
        expenses.where((e) => e.type == 'expense').toList();

    if (expenseList.isEmpty) {
      return OnyxChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            "Log your daily transactions to receive customized savings recommendations and spending leak alerts.",
        isUser: false,
        timestamp: DateTime.now(),
      );
    }

    final Map<String, double> catTotals = {};
    for (final e in expenseList) {
      catTotals[e.category] = (catTotals[e.category] ?? 0.0) + e.amount;
    }

    var topCat = '';
    var topSpend = 0.0;
    catTotals.forEach((cat, val) {
      if (val > topSpend) {
        topSpend = val;
        topCat = cat;
      }
    });

    final potentialSavings10 = topSpend * 0.10;

    return OnyxChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "Actionable Savings Recommendations:\n\n"
          "1. Trim $topCat by 10%: Your highest expense category is $topCat ($currencySymbol${topSpend.toStringAsFixed(0)}). A 10% reduction saves you $currencySymbol${potentialSavings10.toStringAsFixed(0)} each month.\n\n"
          "2. The 48-Hour Rule: For non-essential purchases over $currencySymbol${(topSpend * 0.2).clamp(500, 5000).toStringAsFixed(0)}, pause for 48 hours before buying.\n\n"
          "3. Pay Yourself First: Transfer 15% of your income into a dedicated savings wallet immediately upon receiving it.",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  // --- Greeting & Fallback Handlers ---

  static OnyxChatMessage _handleGreeting() {
    return OnyxChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "Hello! I am Onyx AI, your personal financial advisor.\n\n"
          "You can ask me questions about your finances, such as:\n"
          "• Can I afford to buy a phone for 25,000?\n"
          "• How much did I spend on Food this month?\n"
          "• Summarize my finances\n"
          "• What are my subscriptions?\n"
          "• How much money do I have across wallets?\n\n"
          "How may I assist you with your budget today?",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  static OnyxChatMessage _handleFallback(
    List<Expense> expenses,
    String currencySymbol,
  ) {
    return OnyxChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "I did not find relevant transaction records matching that inquiry. Here are common questions you can ask me:\n\n"
          "• Can I afford to spend ৳10,000?\n"
          "• How much on Food this month?\n"
          "• Summarize my spending\n"
          "• What is my wallet balance?\n\n"
          "Feel free to select a prompt above or ask about any category, amount, or wallet balance.",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
