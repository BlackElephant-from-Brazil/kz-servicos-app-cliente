class MockScheduledTrip {
  final String id;
  final String origin;
  final String destination;
  final DateTime scheduledAt;
  final String driverName;
  final String status;

  const MockScheduledTrip({
    required this.id,
    required this.origin,
    required this.destination,
    required this.scheduledAt,
    required this.driverName,
    required this.status,
  });

  static final List<MockScheduledTrip> samples = [
    MockScheduledTrip(
      id: 'sched_1',
      origin: 'Rua Augusta, 1200 - Consolação',
      destination: 'Aeroporto de Guarulhos - Terminal 2',
      scheduledAt: DateTime(2026, 4, 15, 8, 30),
      driverName: 'João Silva',
      status: 'confirmed',
    ),
    MockScheduledTrip(
      id: 'sched_2',
      origin: 'Av. Paulista, 1578',
      destination: 'Shopping Eldorado',
      scheduledAt: DateTime(2026, 4, 16, 14, 0),
      driverName: 'Maria Santos',
      status: 'pending',
    ),
  ];
}
