import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/features/profile/data/models/mock_card.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final List<MockPaymentCard> _cards = List.from(MockPaymentCard.samples);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 8),
          _buildHeader(context),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_cards.isNotEmpty) ...[
                    const Text(
                      'Meus Cartões',
                      style: TextStyle(
                        fontFamily: 'OutfitBlack',
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._cards.map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PaymentCardTile(
                          card: card,
                          onDelete: () => _removeCard(card),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _AddCardButton(onTap: () => _showAddCardSheet(context)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 22,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Carteira',
              style: TextStyle(
                fontFamily: 'OutfitBlack',
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeCard(MockPaymentCard card) {
    setState(() {
      _cards.removeWhere((c) => c.id == card.id);
    });
  }

  void _showAddCardSheet(BuildContext context) {
    final numberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
    bool isDebit = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              24,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Adicionar Cartão',
                  style: TextStyle(
                    fontFamily: 'OutfitBlack',
                    fontSize: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _CardTextField(
                  controller: numberCtrl,
                  label: 'Número do cartão',
                  hint: '0000 0000 0000 0000',
                  keyboard: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                ),
                const SizedBox(height: 12),
                _CardTextField(
                  controller: nameCtrl,
                  label: 'Nome no cartão',
                  hint: 'NOME COMPLETO',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CardTextField(
                        controller: expiryCtrl,
                        label: 'Validade',
                        hint: 'MM/AA',
                        keyboard: TextInputType.number,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          _ExpiryDateFormatter(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CardTextField(
                        controller: cvvCtrl,
                        label: 'CVV',
                        hint: '000',
                        keyboard: TextInputType.number,
                        obscure: true,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Tipo:',
                      style: TextStyle(
                        fontFamily: 'QuasimodoSemiBold',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _TypeChip(
                      label: 'Crédito',
                      isSelected: !isDebit,
                      onTap: () =>
                          setSheetState(() => isDebit = false),
                    ),
                    const SizedBox(width: 8),
                    _TypeChip(
                      label: 'Débito',
                      isSelected: isDebit,
                      onTap: () =>
                          setSheetState(() => isDebit = true),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final number = numberCtrl.text.replaceAll(' ', '');
                      if (number.length < 12) return;
                      setState(() {
                        _cards.add(MockPaymentCard(
                          id: 'card_new_${_cards.length}',
                          lastFourDigits: number.substring(
                            number.length - 4,
                          ),
                          brand: _detectBrand(number),
                          holderName: nameCtrl.text.isNotEmpty
                              ? nameCtrl.text
                              : 'Titular',
                          expiryDate: expiryCtrl.text,
                          isDebit: isDebit,
                        ));
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Adicionar',
                      style: TextStyle(
                        fontFamily: 'OutfitBlack',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _detectBrand(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'Mastercard';
    if (number.startsWith('3')) return 'Amex';
    return 'Cartão';
  }
}

class _PaymentCardTile extends StatelessWidget {
  final MockPaymentCard card;
  final VoidCallback onDelete;

  const _PaymentCardTile({
    required this.card,
    required this.onDelete,
  });

  IconData get _brandIcon {
    return switch (card.brand) {
      'Visa' => Icons.credit_card,
      'Mastercard' => Icons.credit_card,
      _ => Icons.credit_card,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _brandIcon,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${card.brand} •••• ${card.lastFourDigits}',
                  style: const TextStyle(
                    fontFamily: 'QuasimodoSemiBold',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${card.isDebit ? "Débito" : "Crédito"} • ${card.expiryDate}',
                  style: const TextStyle(
                    fontFamily: 'QuasimodoSemiBold',
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFF999999),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCardButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCardButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: AppColors.secondary, size: 22),
            SizedBox(width: 8),
            Text(
              'Adicionar Cartão',
              style: TextStyle(
                fontFamily: 'QuasimodoSemiBold',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboard;
  final bool obscure;
  final List<TextInputFormatter>? formatters;

  const _CardTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboard,
    this.obscure = false,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      inputFormatters: formatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          fontFamily: 'QuasimodoSemiBold',
          fontSize: 14,
          color: Color(0xFF999999),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'QuasimodoSemiBold',
          fontSize: 14,
          color: Color(0xFFBDBDBD),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.secondary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      style: const TextStyle(
        fontFamily: 'QuasimodoSemiBold',
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'QuasimodoSemiBold',
            fontSize: 13,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length >= 2) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}/${text.substring(2)}',
        selection: TextSelection.collapsed(
          offset: text.length + 1,
        ),
      );
    }
    return newValue;
  }
}
