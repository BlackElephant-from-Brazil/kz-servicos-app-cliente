class MockUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final double profileCompletion;
  final int completedTrips;
  final int requestedServices;
  final int unreadMessages;

  const MockUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.profileCompletion,
    required this.completedTrips,
    required this.requestedServices,
    required this.unreadMessages,
  });

  static final MockUser sample = MockUser(
    id: 'user_1',
    name: 'Ana Carolina',
    email: 'ana.carolina@email.com',
    avatarUrl: null,
    profileCompletion: 0.75,
    completedTrips: 24,
    requestedServices: 8,
    unreadMessages: 3,
  );
}
