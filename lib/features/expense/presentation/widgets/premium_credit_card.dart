import 'package:flutter/material.dart';

class PremiumCreditCard extends StatelessWidget {
  final String cardHolderName;
  final String cardNumber;
  final String expiryDate;

  const PremiumCreditCard({
    super.key,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
  });

  String _detectCardType(String number) {
    final clean = number.replaceAll(RegExp(r'\s+'), '');
    if (clean.startsWith('4')) return 'VISA';
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(clean)) return 'MASTERCARD';
    if (RegExp(r'^3[47]').hasMatch(clean)) return 'AMEX';
    if (RegExp(r'^(6011|65)').hasMatch(clean)) return 'DISCOVER';
    if (RegExp(r'^35').hasMatch(clean)) return 'JCB';
    return 'CARD';
  }

  String _formatCardNumber(String number) {
    final clean = number.replaceAll(' ', '');
    if (clean.isEmpty) return '•••• •••• •••• ••••';
    if (clean.length <= 4) {
      return '•••• •••• •••• $clean';
    }
    final buf = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      buf.write(clean[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != clean.length) {
        buf.write(' ');
      }
    }
    return buf.toString();
  }

  List<Color> _getCardGradient(String type) {
    switch (type) {
      case 'VISA':
        return [
          const Color(0xFF0D47A1),
          const Color(0xFF1976D2),
          const Color(0xFF00838F),
        ];
      case 'MASTERCARD':
        return [
          const Color(0xFF212121),
          const Color(0xFF424242),
          const Color(0xFFE65100),
        ];
      case 'AMEX':
        return [
          const Color(0xFF004D40),
          const Color(0xFF00796B),
          const Color(0xFF80D8FF),
        ];
      case 'DISCOVER':
        return [
          const Color(0xFFE65100),
          const Color(0xFFF57C00),
          const Color(0xFFFFB74D),
        ];
      case 'JCB':
        return [
          const Color(0xFF311B92),
          const Color(0xFFC2185B),
          const Color(0xFFE91E63),
        ];
      default:
        return [
          const Color(0xFF311B92),
          const Color(0xFF5E35B1),
          const Color(0xFF7B1FA2),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardType = _detectCardType(cardNumber);
    final gradientColors = _getCardGradient(cardType);

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withAlpha(80),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(20),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -50,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cardType == 'CARD' ? 'DEBIT CARD' : '$cardType DEBIT',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        cardType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 26,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Contactless icon simulation
                      Icon(
                        Icons.wifi_tethering_rounded,
                        color: Colors.white.withAlpha(120),
                        size: 16,
                      ),
                    ],
                  ),
                  Text(
                    _formatCardNumber(cardNumber),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CARD HOLDER',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 8,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cardHolderName.isEmpty
                                ? 'JOHN DOE'
                                : cardHolderName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EXPIRES',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 8,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            expiryDate.isEmpty ? 'MM/YY' : expiryDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
