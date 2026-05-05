import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_room.dart';
import 'package:kz_servicos_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/messages_cubit.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/messages_state.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/scheduled_trip.dart';
import 'package:kz_servicos_app/features/trip/domain/repositories/trip_repository.dart';

class MockTripRepository extends Mock implements TripRepository {}
class MockChatRepository extends Mock implements ChatRepository {}

final _sampleTrip = ScheduledTrip(
  id: 'trip-1',
  status: 'scheduled',
  scheduledDatetime: DateTime(2026, 5, 10, 10, 0),
  origin: 'Rua A, 10',
  destination: 'Rua B, 20',
  originLat: -23.55,
  originLng: -46.63,
  destinationLat: -23.57,
  destinationLng: -46.69,
  passengerCount: 1,
);

final _sampleRoom = ChatRoom(
  id: 'room-1',
  tripId: 'trip-1',
  clientId: 'client-1',
  providerId: 'driver-1',
  isActive: true,
  createdAt: DateTime(2026, 5, 1),
);

void main() {
  late MockTripRepository mockTripRepo;
  late MockChatRepository mockChatRepo;
  late MessagesCubit cubit;

  setUp(() {
    mockTripRepo = MockTripRepository();
    mockChatRepo = MockChatRepository();
    cubit = MessagesCubit(
      tripRepository: mockTripRepo,
      chatRepository: mockChatRepo,
      clientId: 'client-1',
    );
  });

  tearDown(() => cubit.close());

  test('initial state is MessagesInitial', () {
    expect(cubit.state, isA<MessagesInitial>());
  });

  blocTest<MessagesCubit, MessagesState>(
    'load emits Loading then Loaded on success',
    build: () {
      when(() => mockTripRepo.getChatEligibleTrips('client-1'))
          .thenAnswer((_) async => [_sampleTrip]);
      when(() => mockChatRepo.getRoomsForTrips(['trip-1']))
          .thenAnswer((_) async => {'trip-1': _sampleRoom});
      when(() => mockChatRepo.getLastMessages(['room-1']))
          .thenAnswer((_) async => {'room-1': null});
      when(() => mockChatRepo.getUnreadCounts(['room-1'], 'client-1'))
          .thenAnswer((_) async => {'room-1': 0});
      return cubit;
    },
    act: (c) => c.load(),
    expect: () => [
      isA<MessagesLoading>(),
      isA<MessagesLoaded>().having(
        (s) => s.trips.length,
        'trips count',
        1,
      ),
    ],
  );

  blocTest<MessagesCubit, MessagesState>(
    'load emits Loaded with empty maps when no trips',
    build: () {
      when(() => mockTripRepo.getChatEligibleTrips('client-1'))
          .thenAnswer((_) async => []);
      return cubit;
    },
    act: (c) => c.load(),
    expect: () => [
      isA<MessagesLoading>(),
      isA<MessagesLoaded>().having((s) => s.trips, 'trips', isEmpty),
    ],
  );

  blocTest<MessagesCubit, MessagesState>(
    'load emits Error on failure',
    build: () {
      when(() => mockTripRepo.getChatEligibleTrips('client-1'))
          .thenThrow(Exception('DB error'));
      return cubit;
    },
    act: (c) => c.load(),
    expect: () => [
      isA<MessagesLoading>(),
      isA<MessagesError>(),
    ],
  );
}
