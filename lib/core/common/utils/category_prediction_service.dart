/// Advanced NLP & Weighted-Token Category Prediction Engine
/// Predicts the best matching category with high precision using:
/// 1. Whole-word token matching (avoids false substring matches like "cat" in "education")
/// 2. Multi-word phrase matching
/// 3. Weighted scoring per keyword
/// 4. Stemming & normalization (plurals, suffixes)
class CategoryPredictionService {
  // Keyword definitions with weights:
  // [keyword, weight] where weight:
  // 20 = unique high-confidence term (e.g. 'uber', 'iphone', 'netflix', 'salary')
  // 15 = specific category noun (e.g. 'phone', 'car', 'vaccine', 'burger', 'tuition')
  // 10 = standard category noun (e.g. 'doctor', 'ticket', 'flight', 'dinner')
  // 4  = general helper / verb (e.g. 'buy', 'purchase', 'fee', 'charge')

  static const Map<String, List<MapEntry<String, int>>> _expenseKeywords = {
    'Tech & Gadgets': [
      MapEntry('phone', 18),
      MapEntry('smartphone', 20),
      MapEntry('mobile', 15),
      MapEntry('iphone', 20),
      MapEntry('android', 20),
      MapEntry('samsung', 20),
      MapEntry('xiaomi', 20),
      MapEntry('pixel', 18),
      MapEntry('oneplus', 20),
      MapEntry('tablet', 18),
      MapEntry('ipad', 20),
      MapEntry('macbook', 20),
      MapEntry('laptop', 20),
      MapEntry('computer', 18),
      MapEntry('pc', 15),
      MapEntry('gadget', 18),
      MapEntry('gadgets', 18),
      MapEntry('smartwatch', 20),
      MapEntry('airpods', 20),
      MapEntry('earbuds', 18),
      MapEntry('earphone', 18),
      MapEntry('headphone', 18),
      MapEntry('headset', 18),
      MapEntry('charger', 15),
      MapEntry('powerbank', 18),
      MapEntry('cable', 12),
      MapEntry('keyboard', 16),
      MapEntry('mouse', 14),
      MapEntry('monitor', 16),
      MapEntry('display', 12),
      MapEntry('camera', 16),
      MapEntry('speaker', 15),
      MapEntry('bluetooth', 14),
      MapEntry('tech', 15),
      MapEntry('electronics', 18),
      MapEntry('hardware', 15),
      MapEntry('gpu', 20),
      MapEntry('ram', 15),
      MapEntry('ssd', 18),
      MapEntry('hard drive', 20),
      MapEntry('usb', 15),
      MapEntry('playstation', 18),
      MapEntry('ps5', 20),
      MapEntry('xbox', 18),
      MapEntry('nintendo', 18),
    ],
    'Transport': [
      MapEntry('car', 18),
      MapEntry('car buy', 25),
      MapEntry('buy car', 25),
      MapEntry('car purchase', 25),
      MapEntry('bike', 18),
      MapEntry('motorcycle', 20),
      MapEntry('scooter', 18),
      MapEntry('vehicle', 18),
      MapEntry('bus', 18),
      MapEntry('train', 18),
      MapEntry('metro', 18),
      MapEntry('subway', 15),
      MapEntry('railway', 18),
      MapEntry('rickshaw', 18),
      MapEntry('cng', 18),
      MapEntry('auto rickshaw', 20),
      MapEntry('fare', 15),
      MapEntry('bus fare', 22),
      MapEntry('transit', 16),
      MapEntry('ferry', 18),
      MapEntry('boat', 14),
      MapEntry('trolley', 14),
      MapEntry('transport', 20),
    ],
    'Travel': [
      MapEntry('uber', 22),
      MapEntry('lyft', 22),
      MapEntry('pathao', 22),
      MapEntry('taxi', 20),
      MapEntry('cab', 18),
      MapEntry('fuel', 18),
      MapEntry('petrol', 20),
      MapEntry('gasoline', 20),
      MapEntry('diesel', 18),
      MapEntry('octane', 18),
      MapEntry('gas station', 20),
      MapEntry('parking', 18),
      MapEntry('toll', 18),
      MapEntry('flight', 22),
      MapEntry('airline', 22),
      MapEntry('airways', 22),
      MapEntry('plane', 18),
      MapEntry('biman', 20),
      MapEntry('hotel', 18),
      MapEntry('resort', 18),
      MapEntry('airbnb', 22),
      MapEntry('trip', 16),
      MapEntry('tour', 16),
      MapEntry('travel', 20),
      MapEntry('vacation', 18),
      MapEntry('sightseeing', 18),
      MapEntry('passport', 18),
      MapEntry('visa', 18),
    ],
    'Health': [
      MapEntry('vaccine', 22),
      MapEntry('vaccination', 22),
      MapEntry('doctor', 20),
      MapEntry('hospital', 20),
      MapEntry('clinic', 18),
      MapEntry('pharmacy', 20),
      MapEntry('medicine', 20),
      MapEntry('medicines', 20),
      MapEntry('meds', 18),
      MapEntry('drug', 15),
      MapEntry('drugs', 15),
      MapEntry('prescription', 20),
      MapEntry('dental', 20),
      MapEntry('dentist', 20),
      MapEntry('teeth', 16),
      MapEntry('therapy', 18),
      MapEntry('checkup', 18),
      MapEntry('lab test', 20),
      MapEntry('blood test', 20),
      MapEntry('xray', 20),
      MapEntry('mri', 20),
      MapEntry('surgery', 20),
      MapEntry('bandage', 16),
      MapEntry('ambulance', 20),
      MapEntry('optical', 18),
      MapEntry('glasses', 16),
      MapEntry('eye test', 20),
      MapEntry('physiotherapy', 20),
      MapEntry('health', 18),
      MapEntry('medical', 20),
    ],
    'Food': [
      MapEntry('burger', 20),
      MapEntry('pizza', 20),
      MapEntry('kfc', 22),
      MapEntry('mcdonald', 22),
      MapEntry('mcdonalds', 22),
      MapEntry('coffee', 20),
      MapEntry('starbucks', 22),
      MapEntry('subway', 18),
      MapEntry('lunch', 18),
      MapEntry('dinner', 18),
      MapEntry('breakfast', 18),
      MapEntry('brunch', 18),
      MapEntry('tea', 16),
      MapEntry('cafe', 18),
      MapEntry('bakery', 18),
      MapEntry('snack', 16),
      MapEntry('snacks', 16),
      MapEntry('shawarma', 20),
      MapEntry('sandwich', 18),
      MapEntry('biryani', 22),
      MapEntry('noodles', 18),
      MapEntry('pasta', 18),
      MapEntry('cake', 16),
      MapEntry('pastry', 16),
      MapEntry('ice cream', 20),
      MapEntry('juice', 15),
      MapEntry('drinks', 14),
      MapEntry('beverage', 15),
      MapEntry('sweet', 14),
      MapEntry('sweets', 14),
      MapEntry('food', 18),
    ],
    'Dining Out': [
      MapEntry('restaurant', 22),
      MapEntry('buffet', 22),
      MapEntry('dine', 20),
      MapEntry('dining', 20),
      MapEntry('dining out', 25),
      MapEntry('bistro', 20),
      MapEntry('steakhouse', 22),
      MapEntry('barbecue', 20),
      MapEntry('bbq', 20),
      MapEntry('eatery', 18),
      MapEntry('lounge', 16),
    ],
    'Groceries': [
      MapEntry('grocery', 22),
      MapEntry('groceries', 22),
      MapEntry('supermarket', 22),
      MapEntry('market', 16),
      MapEntry('bazar', 20),
      MapEntry('shwapno', 22),
      MapEntry('agora', 20),
      MapEntry('meenabazar', 22),
      MapEntry('walmart', 22),
      MapEntry('target', 16),
      MapEntry('costco', 22),
      MapEntry('vegetables', 20),
      MapEntry('vegetable', 20),
      MapEntry('fruits', 20),
      MapEntry('fruit', 20),
      MapEntry('meat', 18),
      MapEntry('chicken', 16),
      MapEntry('beef', 18),
      MapEntry('fish', 18),
      MapEntry('milk', 18),
      MapEntry('egg', 18),
      MapEntry('eggs', 18),
      MapEntry('butter', 18),
      MapEntry('cheese', 16),
      MapEntry('oil', 16),
      MapEntry('cooking oil', 22),
      MapEntry('rice', 18),
      MapEntry('salt', 16),
      MapEntry('sugar', 16),
      MapEntry('flour', 16),
      MapEntry('bread', 16),
      MapEntry('onion', 18),
      MapEntry('potato', 18),
      MapEntry('spices', 18),
    ],
    'Bills': [
      MapEntry('electricity', 22),
      MapEntry('electric', 20),
      MapEntry('electric bill', 25),
      MapEntry('desco', 22),
      MapEntry('dpdc', 22),
      MapEntry('nesco', 22),
      MapEntry('reb', 20),
      MapEntry('wasa', 22),
      MapEntry('water bill', 25),
      MapEntry('gas bill', 25),
      MapEntry('titas', 22),
      MapEntry('wifi', 22),
      MapEntry('internet', 20),
      MapEntry('broadband', 22),
      MapEntry('fiber', 18),
      MapEntry('phone bill', 22),
      MapEntry('mobile bill', 22),
      MapEntry('recharge', 20),
      MapEntry('mobile recharge', 25),
      MapEntry('bill', 16),
      MapEntry('bills', 16),
    ],
    'Subscriptions': [
      MapEntry('subscription', 22),
      MapEntry('subscriptions', 22),
      MapEntry('netflix', 22),
      MapEntry('spotify', 22),
      MapEntry('youtube premium', 25),
      MapEntry('icloud', 22),
      MapEntry('apple one', 22),
      MapEntry('chatgpt', 22),
      MapEntry('openai', 22),
      MapEntry('prime video', 22),
      MapEntry('disney', 20),
      MapEntry('hulu', 20),
      MapEntry('patreon', 22),
      MapEntry('medium', 18),
      MapEntry('crunchyroll', 22),
    ],
    'Entertainment': [
      MapEntry('movie', 20),
      MapEntry('movies', 20),
      MapEntry('cinema', 22),
      MapEntry('cineplex', 22),
      MapEntry('theater', 18),
      MapEntry('theatre', 18),
      MapEntry('concert', 22),
      MapEntry('game', 16),
      MapEntry('games', 16),
      MapEntry('gaming', 18),
      MapEntry('steam', 20),
      MapEntry('pubg', 20),
      MapEntry('amusement', 18),
      MapEntry('waterpark', 20),
      MapEntry('fair', 14),
      MapEntry('circus', 18),
      MapEntry('show', 14),
      MapEntry('entertainment', 20),
    ],
    'Shopping': [
      MapEntry('shopping', 22),
      MapEntry('mall', 18),
      MapEntry('amazon', 20),
      MapEntry('daraz', 20),
      MapEntry('ebay', 20),
      MapEntry('aliexpress', 20),
      MapEntry('shein', 20),
      MapEntry('zara', 22),
      MapEntry('h&m', 22),
      MapEntry('nike', 20),
      MapEntry('adidas', 20),
      MapEntry('clothes', 20),
      MapEntry('clothing', 20),
      MapEntry('shirt', 18),
      MapEntry('tshirt', 18),
      MapEntry('pants', 18),
      MapEntry('jeans', 18),
      MapEntry('dress', 18),
      MapEntry('shoes', 20),
      MapEntry('sneakers', 20),
      MapEntry('jacket', 18),
      MapEntry('suit', 18),
      MapEntry('watch', 16),
      MapEntry('bag', 16),
      MapEntry('perfume', 18),
      MapEntry('makeup', 18),
      MapEntry('cosmetics', 18),
      MapEntry('jewelry', 20),
      MapEntry('gold', 16),
    ],
    'Education': [
      MapEntry('tuition', 22),
      MapEntry('school', 20),
      MapEntry('college', 20),
      MapEntry('university', 20),
      MapEntry('semester', 20),
      MapEntry('admission', 20),
      MapEntry('exam', 18),
      MapEntry('exam fee', 22),
      MapEntry('course', 18),
      MapEntry('udemy', 22),
      MapEntry('coursera', 22),
      MapEntry('ielts', 22),
      MapEntry('book', 18),
      MapEntry('books', 18),
      MapEntry('library', 18),
      MapEntry('coaching', 20),
      MapEntry('education', 20),
      MapEntry('stationery', 18),
      MapEntry('pen', 12),
      MapEntry('notebook', 16),
    ],
    'Fitness & Gym': [
      MapEntry('gym', 22),
      MapEntry('fitness', 20),
      MapEntry('workout', 20),
      MapEntry('crossfit', 22),
      MapEntry('yoga', 20),
      MapEntry('protein', 20),
      MapEntry('whey', 20),
      MapEntry('creatine', 20),
      MapEntry('supplements', 18),
      MapEntry('dumbbells', 20),
      MapEntry('treadmill', 20),
      MapEntry('swimming', 18),
    ],
    'Rent/Home': [
      MapEntry('house rent', 25),
      MapEntry('flat rent', 25),
      MapEntry('room rent', 25),
      MapEntry('apartment rent', 25),
      MapEntry('office rent', 25),
      MapEntry('rent', 18),
      MapEntry('apartment', 16),
      MapEntry('furniture', 20),
      MapEntry('sofa', 18),
      MapEntry('bed', 16),
      MapEntry('curtain', 16),
      MapEntry('home decor', 20),
      MapEntry('decor', 14),
      MapEntry('appliance', 18),
      MapEntry('fridge', 18),
      MapEntry('refrigerator', 18),
      MapEntry('ac', 16),
      MapEntry('air conditioner', 22),
      MapEntry('fan', 14),
      MapEntry('washing machine', 20),
    ],
    'Maintenance': [
      MapEntry('plumber', 22),
      MapEntry('electrician', 22),
      MapEntry('carpenter', 22),
      MapEntry('repair', 20),
      MapEntry('maintenance', 20),
      MapEntry('servicing', 18),
      MapEntry('car servicing', 22),
      MapEntry('bike servicing', 22),
      MapEntry('cleaning', 18),
      MapEntry('mechanic', 20),
      MapEntry('paint', 16),
    ],
    'Pets': [
      MapEntry('pet', 20),
      MapEntry('pets', 20),
      MapEntry('dog', 20),
      MapEntry('cat', 20),
      MapEntry('puppy', 20),
      MapEntry('kitten', 20),
      MapEntry('pet food', 25),
      MapEntry('dog food', 25),
      MapEntry('cat food', 25),
      MapEntry('vet', 20),
      MapEntry('veterinary', 22),
      MapEntry('aquarium', 20),
    ],
    'Insurance': [
      MapEntry('insurance', 22),
      MapEntry('life insurance', 25),
      MapEntry('car insurance', 25),
      MapEntry('health insurance', 25),
      MapEntry('metlife', 22),
      MapEntry('policy', 18),
      MapEntry('premium', 16),
    ],
    'Taxes & Fees': [
      MapEntry('tax', 20),
      MapEntry('taxes', 20),
      MapEntry('income tax', 25),
      MapEntry('vat', 20),
      MapEntry('govt fee', 22),
      MapEntry('fine', 18),
      MapEntry('penalty', 18),
    ],
    'Gifts & Charity': [
      MapEntry('charity', 22),
      MapEntry('donation', 22),
      MapEntry('zakat', 25),
      MapEntry('fitra', 25),
      MapEntry('sadakah', 25),
      MapEntry('gift', 18),
      MapEntry('present', 16),
      MapEntry('tip', 16),
      MapEntry('tips', 16),
    ],
  };

  static const Map<String, List<MapEntry<String, int>>> _incomeKeywords = {
    'Salary': [
      MapEntry('salary', 25),
      MapEntry('monthly salary', 25),
      MapEntry('paycheck', 25),
      MapEntry('wage', 22),
      MapEntry('wages', 22),
      MapEntry('monthly pay', 25),
      MapEntry('office pay', 25),
      MapEntry('office', 15),
      MapEntry('payroll', 22),
      MapEntry('stipend', 22),
      MapEntry('remuneration', 22),
      MapEntry('job pay', 22),
      MapEntry('allowance', 18),
      MapEntry('payday', 22),
    ],
    'Bonus': [
      MapEntry('bonus', 25),
      MapEntry('eid bonus', 25),
      MapEntry('festive bonus', 25),
      MapEntry('performance bonus', 25),
      MapEntry('incentive', 22),
      MapEntry('commission', 22),
      MapEntry('award', 20),
      MapEntry('appreciation', 18),
    ],
    'Freelance': [
      MapEntry('freelance', 25),
      MapEntry('upwork', 25),
      MapEntry('fiverr', 25),
      MapEntry('toptal', 25),
      MapEntry('client work', 22),
      MapEntry('gig', 20),
      MapEntry('contract', 18),
      MapEntry('project pay', 22),
      MapEntry('hourly rate', 22),
      MapEntry('coding', 16),
      MapEntry('dev work', 20),
      MapEntry('design work', 20),
    ],
    'Business': [
      MapEntry('business', 22),
      MapEntry('sales', 22),
      MapEntry('store sales', 22),
      MapEntry('shop sales', 22),
      MapEntry('revenue', 22),
      MapEntry('invoice', 20),
      MapEntry('customer payment', 25),
      MapEntry('client payment', 25),
      MapEntry('profit', 20),
      MapEntry('merchant', 18),
      MapEntry('order', 16),
    ],
    'Investment': [
      MapEntry('investment', 22),
      MapEntry('stocks', 22),
      MapEntry('stock', 20),
      MapEntry('crypto', 22),
      MapEntry('bitcoin', 25),
      MapEntry('eth', 20),
      MapEntry('binance', 22),
      MapEntry('trading', 20),
      MapEntry('mutual fund', 22),
      MapEntry('interest', 20),
      MapEntry('bank interest', 25),
      MapEntry('fdr', 22),
      MapEntry('dps', 22),
      MapEntry('capital gain', 22),
    ],
    'Dividend': [
      MapEntry('dividend', 25),
      MapEntry('dividends', 25),
      MapEntry('stock dividend', 25),
      MapEntry('quarterly dividend', 25),
    ],
    'Rental': [
      MapEntry('rent received', 25),
      MapEntry('rental income', 25),
      MapEntry('tenant', 22),
      MapEntry('house rent income', 25),
      MapEntry('sublet', 22),
      MapEntry('flat rent received', 25),
    ],
    'Refund': [
      MapEntry('refund', 25),
      MapEntry('cashback', 25),
      MapEntry('reimbursement', 25),
      MapEntry('return', 18),
      MapEntry('rebate', 20),
      MapEntry('chargeback', 22),
    ],
  };

  /// Predicts the category for the given title and transaction type ('expense' or 'income').
  /// Uses NLP tokenization and weighted scoring.
  static String? predictCategory(String title, String transactionType) {
    final clean = title.trim().toLowerCase();
    if (clean.length < 2) return null;

    // Normalize: replace punctuation with space, collapse multi-spaces
    final normalized = clean
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (normalized.isEmpty) return null;

    final rawTokens = normalized.split(' ');
    // Build token set with stemming (e.g. phones -> phone, cars -> car)
    final Set<String> tokenSet = {};
    for (var token in rawTokens) {
      tokenSet.add(token);
      // Strip trailing 's' or 'es' for simple plurals
      if (token.endsWith('es') && token.length > 4) {
        tokenSet.add(token.substring(0, token.length - 2));
      } else if (token.endsWith('s') && token.length > 3) {
        tokenSet.add(token.substring(0, token.length - 1));
      }
      // Strip trailing 'ing'
      if (token.endsWith('ing') && token.length > 5) {
        tokenSet.add(token.substring(0, token.length - 3));
      }
    }

    final keywordsMap =
        transactionType == 'income' ? _incomeKeywords : _expenseKeywords;

    String? bestCategory;
    int highestScore = 0;

    for (var entry in keywordsMap.entries) {
      final categoryName = entry.key;
      int categoryScore = 0;

      for (var kwEntry in entry.value) {
        final keyword = kwEntry.key;
        final weight = kwEntry.value;

        if (keyword.contains(' ')) {
          // Multi-word phrase check (e.g. "car buy", "vaccination fee")
          if (normalized.contains(keyword)) {
            categoryScore += weight + 10;
          }
        } else {
          // Single word: must match exact whole token
          if (tokenSet.contains(keyword)) {
            categoryScore += weight;
          } else if (keyword.length >= 5) {
            // Partial root match for longer words (e.g. "vaccin" in "vaccination")
            for (var t in tokenSet) {
              if (t.startsWith(keyword) || keyword.startsWith(t)) {
                categoryScore += (weight * 0.7).toInt();
                break;
              }
            }
          }
        }
      }

      if (categoryScore > highestScore) {
        highestScore = categoryScore;
        bestCategory = categoryName;
      }
    }

    // Minimum threshold score of 8 required for a confident auto-categorization
    if (highestScore >= 8) {
      return bestCategory;
    }

    return null;
  }
}
