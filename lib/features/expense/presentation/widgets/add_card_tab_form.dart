import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/premium_credit_card.dart';

class AddCardTabForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController numberController;
  final TextEditingController balanceController;
  final FocusNode nameFocusNode;
  final FocusNode numberFocusNode;
  final FocusNode balanceFocusNode;
  final VoidCallback onChanged;
  final Function(String userId) onSaveCard;
  final String userId;

  const AddCardTabForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.numberController,
    required this.balanceController,
    required this.nameFocusNode,
    required this.numberFocusNode,
    required this.balanceFocusNode,
    required this.onChanged,
    required this.onSaveCard,
    required this.userId,
  });

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.8,
        ),
      );

  InputDecoration _inputDeco(BuildContext context, String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      fillColor: isDark ? Colors.white10 : Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 8),
          PremiumCreditCard(
            cardHolderName: nameController.text.isEmpty
                ? 'JOHN DOE'
                : nameController.text.toUpperCase(),
            cardNumber: numberController.text.isEmpty
                ? '•••• •••• •••• ••••'
                : numberController.text,
            expiryDate: 'MM/YY',
          ),
          const SizedBox(height: 24),

          _fieldLabel('NAME ON CARD'),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            focusNode: nameFocusNode,
            onChanged: (_) => onChanged(),
            textCapitalization: TextCapitalization.characters,
            decoration: _inputDeco(context, 'e.g. JOHN DOE'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(numberFocusNode),
          ),
          const SizedBox(height: 16),

          _fieldLabel('CARD NUMBER (LAST 4 DIGITS)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: numberController,
            focusNode: numberFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (val) {
              onChanged();
              if (val.length == 4) {
                FocusScope.of(context).requestFocus(balanceFocusNode);
              }
            },
            decoration: _inputDeco(context, 'e.g. 4321'),
            validator: (v) {
              final clean = (v ?? '').replaceAll(' ', '');
              if (clean.isEmpty) return 'Card number is required';
              if (clean.length < 4) return 'Must be exactly 4 digits';
              return null;
            },
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(balanceFocusNode),
          ),
          const SizedBox(height: 16),

          _fieldLabel('INITIAL BALANCE'),
          const SizedBox(height: 8),
          TextFormField(
            controller: balanceController,
            focusNode: balanceFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDeco(context, '0.00'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null; // Optional balance
              if (double.tryParse(v.trim()) == null) return 'Invalid number';
              return null;
            },
          ),
          const SizedBox(height: 32),

          Container(
            height: 52,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () => onSaveCard(userId),
              child: const Text(
                'Add Card',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
