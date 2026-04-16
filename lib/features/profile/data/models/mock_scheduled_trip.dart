class MockScheduledTrip {
  final String id;
  final String origin;
  final String destination;
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final DateTime scheduledAt;
  final String driverName;
  final String status;

  const MockScheduledTrip({
    required this.id,
    required this.origin,
    required this.destination,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.scheduledAt,
    required this.driverName,
    required this.status,
  });

  static final List<MockScheduledTrip> samples = [
    MockScheduledTrip(
      id: 'sched_1',
      origin: 'Rua Augusta, 1200 - Consolação',
      destination: 'Aeroporto de Guarulhos - Terminal 2',
      originLat: -23.5534,
      originLng: -46.6580,
      destinationLat: -23.4356,
      destinationLng: -46.4731,
      scheduledAt: DateTime(2026, 4, 15, 8, 30),
      driverName: 'João Silva',
      status: 'confirmed',
    ),
    MockScheduledTrip(
      id: 'sched_2',
      origin: 'Av. Paulista, 1578',
      destination: 'Shopping Eldorado',
      originLat: -23.5613,
      originLng: -46.6565,
      destinationLat: -23.5727,
      destinationLng: -46.6951,
      scheduledAt: DateTime(2026, 4, 16, 14, 0),
      driverName: 'Maria Santos',
      status: 'pending',
    ),
  ];
}
