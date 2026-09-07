import 'package:expense_tracker/features/expense/domain/entities/expense.dart';

class BudgetPlan {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final String period; // 'monthly' or 'yearly'
  final String category; // 'All' or specific category like 'Food', 'Salary'
  final DateTime startDate;
  final String? walletId;

  BudgetPlan({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.period,
    this.category = 'All',
    required this.startDate,
    this.walletId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'target_amount': targetAmount,
        'period': period,
        'category': category,
        'start_date': startDate.toIso8601String(),
        'wallet_id': walletId,
      };

  factory BudgetPlan.fromJson(Map<String, dynamic> map) => BudgetPlan(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        name: map['name'] as String,
        targetAmount: (map['target_amount'] as num).toDouble(),
        period: map['period'] as String? ?? 'monthly',
        category: map['category'] as String? ?? 'All',
        startDate: map['start_date'] != null
            ? DateTime.parse(map['start_date'] as String)
            : DateTime.now(),
        walletId: map['wallet_id'] as String?,
      );

  /// Helper method to calculate spent amount from transactions
  double calculateSpent(List<Expense> expenses) {
    double total = 0.0;
    for (final tx in expenses) {
      if (matchesTransaction(tx)) {
        total += tx.amount;
      }
    }
    return total;
  }

  /// Returns list of transactions matching this plan
  List<Expense> getMatchingTransactions(List<Expense> expenses) {
    return expenses.where(matchesTransaction).toList();
  }

  /// Checks whether a given transaction counts against this budget plan
  bool matchesTransaction(Expense tx) {
    if (tx.type != 'expense') return false;

    // Wallet filter (if bound to a specific wallet)
    if (walletId != null && tx.walletId != walletId) {
      return false;
    }

    // Period filter
    final now = DateTime.now();
    if (period == 'monthly') {
      if (tx.date.year != now.year || tx.date.month != now.month) {
        return false;
      }
    } else {
      if (tx.date.year != now.year) {
        return false;
      }
    }

    // Category filter: 'All' matches all expenses in this period
    final planCat = category.toLowerCase().trim();
    if (planCat == 'all' || planCat.isEmpty) {
      return true;
    }

    final txCat = tx.category.toLowerCase().trim();
    final txTitle = tx.title.toLowerCase().trim();
    final txNotes = (tx.notes ?? '').toLowerCase().trim();
    final planTitle = name.toLowerCase().trim();

    return _isCategoryOrTitleMatch(
      planCat: planCat,
      planTitle: planTitle,
      txCat: txCat,
      txTitle: txTitle,
      txNotes: txNotes,
    );
  }

  static bool _isCategoryOrTitleMatch({
    required String planCat,
    required String planTitle,
    required String txCat,
    required String txTitle,
    required String txNotes,
  }) {
    // 1. Direct category match or substring
    if (txCat == planCat || txCat.contains(planCat) || planCat.contains(txCat)) {
      return true;
    }

    // 2. Transaction title matches plan category or plan category matches title
    if (txTitle.contains(planCat) || (planCat.length >= 3 && planCat.contains(txTitle))) {
      return true;
    }

    // 3. Notes match plan category
    if (txNotes.isNotEmpty && txNotes.contains(planCat)) {
      return true;
    }

    // 4. Subcategory keyword cluster check
    for (final entry in _subcategoryKeywords.entries) {
      final subName = entry.key;
      final keywords = entry.value;

      final isThisSubcategory = planCat == subName ||
          planCat.contains(subName) ||
          subName.contains(planCat);

      if (isThisSubcategory) {
        for (final kw in keywords) {
          if (txTitle.contains(kw) || txNotes.contains(kw) || txCat.contains(kw)) {
            return true;
          }
        }
      }
    }

    // 5. Category Group match (Bidirectional)
    for (final entry in _categoryGroups.entries) {
      final groupKey = entry.key;
      final members = entry.value;

      final planInGroup = planCat == groupKey ||
          planCat.contains(groupKey) ||
          members.any((m) => planCat == m || planCat.contains(m));
      if (!planInGroup) continue;

      final isParentPlan = planCat == groupKey || groupKey.contains(planCat);
      if (isParentPlan) {
        // Parent plan matches any tx in this group
        if (txCat == groupKey || txCat.contains(groupKey)) return true;
        if (members.any((m) => txCat == m || txCat.contains(m))) return true;
        if (members.any((m) => txTitle.contains(m))) return true;
      } else {
        // Specific subcategory plan:
        // Match if txTitle mentions any keyword of this subcategory
        final subKw = _subcategoryKeywords[planCat];
        if (subKw != null && subKw.any((k) => txTitle.contains(k) || txNotes.contains(k))) {
          return true;
        }

        // Match if txTitle matches any group member closely related to planCat
        if (members.any((m) => (m.contains(planCat) || planCat.contains(m)) && txTitle.contains(m))) {
          return true;
        }

        // Match if planTitle matches txTitle or txCat
        if (planTitle.isNotEmpty) {
          final words = planTitle.split(RegExp(r'\s+')).where((w) => w.length >= 3);
          for (final word in words) {
            if (txTitle.contains(word) || txCat.contains(word)) return true;
          }
        }
      }
    }

    return false;
  }

  static const Map<String, List<String>> _subcategoryKeywords = {
    // Health
    'pharmacy': [
      'pharmacy', 'medicine', 'medicines', 'meds', 'drug', 'drugs',
      'pharma', 'prescription', 'pill', 'pills', 'chemist'
    ],
    'medical & doctor': [
      'medical', 'doctor', 'hospital', 'clinic', 'test', 'lab', 'checkup',
      'surgery', 'dentist', 'dental', 'health', 'physician', 'physio'
    ],
    'fitness & gym': [
      'gym', 'fitness', 'workout', 'yoga', 'crossfit', 'protein', 'dumbbells',
      'treadmill', 'sports'
    ],

    // Bills
    'utilities': [
      'utility', 'utilities', 'electric', 'electricity', 'water', 'gas',
      'current', 'home bill', 'bill', 'bills', 'wasa', 'desco', 'dpdc',
      'nesco', 'titas', 'power'
    ],
    'electricity': [
      'electric', 'electricity', 'current', 'desco', 'dpdc', 'nesco', 'reb',
      'power', 'electric bill'
    ],
    'internet & wi-fi': [
      'internet', 'wifi', 'wi-fi', 'broadband', 'fiber', 'router', 'net bill',
      'data pack'
    ],
    'mobile recharge': [
      'recharge', 'mobile recharge', 'flexiload', 'topup', 'airtime',
      'phone bill', 'mobile bill'
    ],

    // Food
    'groceries': [
      'grocery', 'groceries', 'supermarket', 'bazar', 'market', 'shwapno',
      'agora', 'meena', 'vegetables', 'meat', 'fish', 'rice', 'milk', 'egg',
      'kitchen', 'food'
    ],
    'dining out': [
      'restaurant', 'dining', 'dinner', 'lunch', 'biryani', 'kfc', 'mcdonald',
      'burger', 'pizza', 'takeout', 'foodpanda', 'treat', 'dine', 'buffet'
    ],
    'cafe & snacks': [
      'cafe', 'coffee', 'tea', 'snacks', 'snack', 'bakery', 'cake',
      'ice cream', 'pastry', 'sweets', 'dessert'
    ],

    // Shopping
    'clothing': [
      'clothes', 'clothing', 'shirt', 'tshirt', 'pants', 'dress', 'shoes',
      'sneakers', 'jacket', 'wear', 'apparel', 'outfit', 'fabric', 'tailor'
    ],
    'tech & gadgets': [
      'tech', 'gadget', 'gadgets', 'iphone', 'iphones', 'phone', 'mobile',
      'laptop', 'macbook', 'computer', 'airpods', 'headphones', 'camera',
      'ipad', 'tablet', 'electronics'
    ],
    'personal care': [
      'salon', 'parlor', 'haircut', 'cosmetics', 'makeup', 'skincare',
      'perfume', 'soap', 'shampoo', 'spa'
    ],

    // Transport
    'fuel & gas': [
      'fuel', 'gas', 'petrol', 'octane', 'diesel', 'cng', 'filling station'
    ],
    'rideshare & taxi': [
      'uber', 'pathao', 'taxi', 'cab', 'rideshare', 'rickshaw'
    ],
    'public transit': [
      'bus', 'train', 'metro', 'commute', 'transit', 'ticket', 'fare'
    ],
    'vehicle maintenance': [
      'car repair', 'servicing', 'mechanic', 'car wash', 'tyre', 'bike service',
      'maintenance'
    ],

    // Entertainment
    'subscriptions': [
      'subscription', 'subscriptions', 'netflix', 'spotify', 'youtube', 'prime',
      'disney', 'chatgpt', 'icloud', 'apple'
    ],
    'movies & streaming': [
      'movie', 'movies', 'cinema', 'cineplex', 'theater', 'theatre', 'film',
      'streaming'
    ],
    'gaming': [
      'game', 'games', 'gaming', 'steam', 'playstation', 'ps5', 'xbox',
      'nintendo', 'pubg'
    ],

    // Rent / Home
    'rent & housing': [
      'rent', 'house rent', 'flat rent', 'room rent', 'housing', 'apartment'
    ],
    'home maintenance': [
      'maintenance', 'repair', 'plumber', 'electrician', 'cleaning', 'paint',
      'appliances'
    ],
    'pets': [
      'pet', 'pets', 'dog', 'cat', 'puppy', 'kitten', 'vet', 'veterinary',
      'pet food'
    ],

    // Education
    'tuition & school': [
      'tuition', 'school', 'college', 'university', 'semester', 'fees',
      'admission', 'coaching', 'student'
    ],
    'online courses': [
      'course', 'courses', 'udemy', 'coursera', 'skillshare', 'training',
      'learning'
    ],
    'books': [
      'book', 'books', 'stationery', 'library', 'pen', 'notebook', 'study'
    ],

    // Family & Kids
    'childcare': ['child', 'baby', 'kids', 'diaper', 'daycare', 'toys'],
    'gifts & charity': [
      'gift', 'gifts', 'charity', 'donation', 'zakat', 'sadakah', 'present'
    ],

    // Travel
    'flights': [
      'flight', 'flights', 'airfare', 'airline', 'airways', 'plane', 'biman',
      'airport'
    ],
    'hotels & stay': [
      'hotel', 'hotels', 'resort', 'stay', 'airbnb', 'room', 'lodge'
    ],
    'vacation': ['trip', 'tour', 'vacation', 'holiday', 'sightseeing', 'travel'],
  };

  static const Map<String, List<String>> _categoryGroups = {
    'food': [
      'food', 'groceries', 'dining out', 'restaurant', 'meal', 'cafe', 'snacks'
    ],
    'shopping': [
      'shopping', 'clothing', 'clothes', 'tech & gadgets', 'electronics',
      'apparel', 'personal care'
    ],
    'transport': [
      'transport', 'travel', 'fuel', 'gas', 'uber', 'taxi', 'commute', 'train',
      'bus'
    ],
    'bills': [
      'bills', 'utilities', 'electricity', 'water', 'internet', 'wifi',
      'recharge', 'subscriptions', 'home bill', 'bill'
    ],
    'health': [
      'health', 'medical', 'medicine', 'doctor', 'pharmacy', 'fitness & gym',
      'gym'
    ],
    'entertainment': [
      'entertainment', 'subscriptions', 'movies', 'cinema', 'gaming', 'netflix',
      'spotify', 'smoking'
    ],
    'education': [
      'education', 'tuition', 'courses', 'school', 'books', 'college'
    ],
    'rent/home': ['rent/home', 'home', 'rent', 'maintenance', 'pets', 'housing'],
    'family & kids': ['family & kids', 'family', 'kids', 'gifts & charity'],
    'travel': ['travel', 'flights', 'hotels', 'stay', 'vacation'],
  };
}
