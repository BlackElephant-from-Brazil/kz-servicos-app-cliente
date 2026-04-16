class MockPaymentCard {
  final String id;
  final String lastFourDigits;
  final String brand;
  final String holderName;
  final String expiryDate;
  final bool isDebit;

  const MockPaymentCard({
    required this.id,
    required this.lastFourDigits,
    required this.brand,
    required this.holderName,
    required this.expiryDate,
    required this.isDebit,
  });

  static final List<MockPaymentCard> samples = [
    const MockPaymentCard(
      id: 'card_1',
      lastFourDigits: '4532',
      brand: 'Visa',
      holderName: 'Ana Carolina',
      expiryDate: '12/28',
      isDebit: false,
    ),
    const MockPaymentCard(
      id: 'card_2',
      lastFourDigits: '8901',
      brand: 'Mastercard',
      holderName: 'Ana Carolina',
      expiryDate: '06/27',
      isDebit: true,
    ),
  ];
}
