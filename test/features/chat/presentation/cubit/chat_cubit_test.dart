import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_message.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_room.dart';
import 'package:kz_servicos_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/chat_state.dart';

class MockChatRepository extends Mock implements ChatRepository {}

final _room = ChatRoom(
  id: 'room-1',
  tripId: 'trip-1',
  clientId: 'client-1',
  providerId: 'driver-1',
  isActive: true,
  createdAt: DateTime(2026, 5, 1),
);

final _msg = ChatMessage(
  id: 'msg-1',
  chatRoomId: 'room-1',
  senderId: 'driver-1',
  message: 'Olá!',
  isFromCurrentUser: false,
  createdAt: DateTime(2026, 5, 1, 10, 0),
  isRead: true,
);

void main() {
  late MockChatRepository mockRepo;
  late StreamController<ChatMessage> realtimeController;

  setUp(() {
    mockRepo = MockChatRepository();
    realtimeController = StreamController<ChatMessage>.broadcast();
  });

  tearDown(() => realtimeController.close());

  ChatCubit buildCubit() => ChatCubit(
        chatRepository: mockRepo,
        currentUserId: 'client-1',
      );

  void stubInit() {
    when(() => mockRepo.getOrCreateRoomForTrip('trip-1'))
        .thenAnswer((_) async => _room);
    when(() => mockRepo.getMessages('room-1'))
        .thenAnswer((_) async => [_msg]);
    when(() => mockRepo.markAllAsRead('room-1', 'client-1'))
        .thenAnswer((_) async {});
    when(() => mockRepo.subscribeToMessages('room-1'))
        .thenAnswer((_) => realtimeController.stream);
  }

  test('initial state is ChatInitial', () {
    expect(buildCubit().state, isA<ChatInitial>());
  });

  blocTest<ChatCubit, ChatState>(
    'init emits Loading then Loaded with messages',
    build: () {
      stubInit();
      return buildCubit();
    },
    act: (c) => c.init('trip-1'),
    expect: () => [
      isA<ChatLoading>(),
      isA<ChatLoaded>().having(
        (s) => s.messages.length,
        'messages count',
        1,
      ),
    ],
  );

  blocTest<ChatCubit, ChatState>(
    'init emits Error when repository throws',
    build: () {
      when(() => mockRepo.getOrCreateRoomForTrip('trip-1'))
          .thenThrow(Exception('Network error'));
      return buildCubit();
    },
    act: (c) => c.init('trip-1'),
    expect: () => [
      isA<ChatLoading>(),
      isA<ChatError>(),
    ],
  );

  blocTest<ChatCubit, ChatState>(
    'Realtime message is appended to loaded messages',
    build: () {
      stubInit();
      return buildCubit();
    },
    act: (c) async {
      await c.init('trip-1');
      realtimeController.add(ChatMessage(
        id: 'msg-2',
        chatRoomId: 'room-1',
        senderId: 'driver-1',
        message: 'A caminho!',
        isFromCurrentUser: false,
        createdAt: DateTime(2026, 5, 1, 10, 5),
        isRead: false,
      ));
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => [
      isA<ChatLoading>(),
      isA<ChatLoaded>().having((s) => s.messages.length, 'count', 1),
      isA<ChatLoaded>().having((s) => s.messages.length, 'count after RT', 2),
    ],
  );
}
