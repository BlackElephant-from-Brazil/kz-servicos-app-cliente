class MockTripHistory {
  final String id;
  final String origin;
  final String destination;
  final DateTime completedAt;
  final double price;
  final String driverName;
  final double rating;

  const MockTripHistory({
    required this.id,
    required this.origin,
    required this.destination,
    required this.completedAt,
    required this.price,
    required this.driverName,
    required this.rating,
  });

  static final List<MockTripHistory> samples = [
    MockTripHistory(
      id: 'hist_1',
      origin: 'Rua Oscar Freire, 379',
      destination: 'Av. Brigadeiro Faria Lima, 3477',
      completedAt: DateTime(2026, 4, 10, 18, 45),
      price: 32.50,
      driverName: 'Carlos Oliveira',
      rating: 5.0,
    ),
    MockTripHistory(
      id: 'hist_2',
      origin: 'Estação da Luz',
      destination: 'Parque Ibirapuera',
      completedAt: DateTime(2026, 4, 8, 10, 20),
      price: 28.00,
      driverName: 'João Silva',
      rating: 4.8,
    ),
  ];
}
