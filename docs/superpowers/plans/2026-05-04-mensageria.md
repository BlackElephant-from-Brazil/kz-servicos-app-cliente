# Mensageria Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Substituir mocks de chat por integração real com Supabase (chat_rooms + chat_messages + Realtime), adicionando botão na tela de detalhes da viagem e conectando as páginas de mensagens e chat à API.

**Architecture:** Clean Architecture com Bloc/Cubit. Nova feature `chat` contém domain + data; a UI já existe em `profile` e será conectada. O `ChatCubit` gerencia uma sala individual (Realtime via StreamSubscription). O `MessagesCubit` carrega viagens elegíveis + rooms em batch. A criação de sala acontece lazily no primeiro acesso ao chat.

**Tech Stack:** Flutter, Dart, supabase_flutter ^2.12.4, flutter_bloc ^9.1.1, equatable ^2.0.8, go_router ^15.1.2 | Tests: bloc_test ^10.0.0, mocktail ^1.0.5

---

## File Map

| Arquivo | Ação |
|---------|------|
| `lib/features/chat/domain/entities/chat_room.dart` | CRIAR |
| `lib/features/chat/domain/entities/chat_message.dart` | CRIAR |
| `lib/features/chat/domain/repositories/chat_repository.dart` | CRIAR |
| `lib/features/chat/data/models/chat_room_model.dart` | CRIAR |
| `lib/features/chat/data/models/chat_message_model.dart` | CRIAR |
| `lib/features/chat/data/repositories/chat_repository_impl.dart` | CRIAR |
| `lib/features/chat/presentation/cubit/messages_state.dart` | CRIAR |
| `lib/features/chat/presentation/cubit/messages_cubit.dart` | CRIAR |
| `lib/features/chat/presentation/cubit/chat_state.dart` | CRIAR |
| `lib/features/chat/presentation/cubit/chat_cubit.dart` | CRIAR |
| `lib/features/trip/domain/repositories/trip_repository.dart` | MODIFICAR |
| `lib/features/trip/data/repositories/trip_repository_impl.dart` | MODIFICAR |
| `lib/features/trip/presentation/widgets/trip_details_sheet.dart` | MODIFICAR |
| `lib/features/profile/presentation/pages/messages_page.dart` | MODIFICAR |
| `lib/features/profile/presentation/pages/chat_page.dart` | MODIFICAR |
| `lib/routes/app_router.dart` | MODIFICAR |
| `test/features/chat/data/models/chat_models_test.dart` | CRIAR |
| `test/features/chat/presentation/cubit/messages_cubit_test.dart` | CRIAR |
| `test/features/chat/presentation/cubit/chat_cubit_test.dart` | CRIAR |

---

## Task 1: Domain entities — ChatRoom e ChatMessage

**Files:**
- Create: `lib/features/chat/domain/entities/chat_room.dart`
- Create: `lib/features/chat/domain/entities/chat_message.dart`

- [ ] **Step 1: Criar `chat_room.dart`**

```dart
// lib/features/chat/domain/entities/chat_room.dart
import 'package:equatable/equatable.dart';

class ChatRoom extends Equatable {
  const ChatRoom({
    required this.id,
    required this.tripId,
    required this.clientId,
    required this.providerId,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String tripId;
  final String clientId;
  final String providerId;
  final bool isActive;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id];
}
```

- [ ] **Step 2: Criar `chat_message.dart`**

```dart
// lib/features/chat/domain/entities/chat_message.dart
import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.message,
    required this.isFromCurrentUser,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String chatRoomId;
  final String senderId;
  final String message;
  final bool isFromCurrentUser;
  final DateTime createdAt;
  final bool isRead;

  @override
  List<Object?> get props => [id];
}
```

- [ ] **Step 3: Verificar análise estática**

```
flutter analyze lib/features/chat/domain/
```

Esperado: zero erros.

- [ ] **Step 4: Commit**

```
git add lib/features/chat/domain/entities/
git commit -m "feat(chat): add ChatRoom and ChatMessage domain entities"
```

---

## Task 2: ChatRepository interface + extensão de TripRepository

**Files:**
- Create: `lib/features/chat/domain/repositories/chat_repository.dart`
- Modify: `lib/features/trip/domain/repositories/trip_repository.dart`

- [ ] **Step 1: Criar `chat_repository.dart`**

```dart
// lib/features/chat/domain/repositories/chat_repository.dart
import '../entities/chat_message.dart';
import '../entities/chat_room.dart';

abstract class ChatRepository {
  /// Retorna a sala existente para o trip, ou cria uma nova.
  Future<ChatRoom> getOrCreateRoomForTrip(String tripId);

  /// Mensagens da sala ordenadas por created_at ASC.
  Future<List<ChatMessage>> getMessages(String chatRoomId);

  /// Envia mensagem de texto.
  Future<ChatMessage> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String text,
  });

  /// Stream de novas mensagens via Supabase Realtime.
  /// Cancelar a StreamSubscription encerra o canal.
  Stream<ChatMessage> subscribeToMessages(String chatRoomId);

  /// Marca como lidas todas as mensagens de outros remetentes.
  Future<void> markAllAsRead(String chatRoomId, String userId);

  /// Retorna salas para múltiplos trips (Map<tripId, ChatRoom?>).
  /// trips sem sala mapeiam para null.
  Future<Map<String, ChatRoom?>> getRoomsForTrips(List<String> tripIds);

  /// Última mensagem por sala (Map<roomId, ChatMessage?>).
  Future<Map<String, ChatMessage?>> getLastMessages(List<String> roomIds);

  /// Contagem de não-lidos por sala para o usuário atual.
  Future<Map<String, int>> getUnreadCounts(
    List<String> roomIds,
    String currentUserId,
  );
}
```

- [ ] **Step 2: Adicionar `getChatEligibleTrips` em `trip_repository.dart`**

Abrir `lib/features/trip/domain/repositories/trip_repository.dart` e adicionar o método ao final da classe abstract (antes do `}`):

```dart
  /// Viagens com status schedulable para chat: scheduled, started, finished.
  /// Ordenadas por scheduled_datetime decrescente.
  Future<List<ScheduledTrip>> getChatEligibleTrips(String clientId);
```

O arquivo final deve ficar:

```dart
import 'package:kz_servicos_app/features/trip/domain/entities/scheduled_trip.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/trip.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/trip_request.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/trip_with_candidates.dart';

abstract class TripRepository {
  Future<Trip> createTrip(TripRequest request);

  Future<List<ScheduledTrip>> getScheduledTrips(String clientId);

  Future<List<TripWithCandidates>> getTripsAwaitingClientConfirmation(
    String clientId,
  );

  Future<void> acceptDriverCandidate({
    required String tripId,
    required String driverProfileId,
    String? vehicleId,
  });

  Future<List<ScheduledTrip>> getChatEligibleTrips(String clientId);
}
```

- [ ] **Step 3: Verificar análise estática**

```
flutter analyze lib/features/chat/domain/ lib/features/trip/domain/
```

Esperado: zero erros.

- [ ] **Step 4: Commit**

```
git add lib/features/chat/domain/repositories/ lib/features/trip/domain/repositories/
git commit -m "feat(chat): add ChatRepository interface and getChatEligibleTrips to TripRepository"
```

---

## Task 3: Data models — ChatRoomModel e ChatMessageModel

**Files:**
- Create: `lib/features/chat/data/models/chat_room_model.dart`
- Create: `lib/features/chat/data/models/chat_message_model.dart`
- Create: `test/features/chat/data/models/chat_models_test.dart`

- [ ] **Step 1: Escrever o teste com falha esperada**

```dart
// test/features/chat/data/models/chat_models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kz_servicos_app/features/chat/data/models/chat_room_model.dart';
import 'package:kz_servicos_app/features/chat/data/models/chat_message_model.dart';

void main() {
  group('ChatRoomModel', () {
    final json = {
      'id': 'room-1',
      'trip_id': 'trip-1',
      'client_id': 'client-1',
      'provider_id': 'driver-user-1',
      'is_active': true,
      'created_at': '2026-05-01T10:00:00.000Z',
    };

    test('fromJson parses all fields', () {
      final model = ChatRoomModel.fromJson(json);
      expect(model.id, 'room-1');
      expect(model.tripId, 'trip-1');
      expect(model.clientId, 'client-1');
      expect(model.providerId, 'driver-user-1');
      expect(model.isActive, true);
    });

    test('toEntity maps fields correctly', () {
      final entity = ChatRoomModel.fromJson(json).toEntity();
      expect(entity.id, 'room-1');
      expect(entity.tripId, 'trip-1');
      expect(entity.props, ['room-1']);
    });
  });

  group('ChatMessageModel', () {
    final json = {
      'id': 'msg-1',
      'chat_room_id': 'room-1',
      'sender_id': 'client-1',
      'message': 'Olá!',
      'is_read': false,
      'created_at': '2026-05-01T10:05:00.000Z',
    };

    test('fromJson parses all fields', () {
      final model = ChatMessageModel.fromJson(json);
      expect(model.id, 'msg-1');
      expect(model.senderId, 'client-1');
      expect(model.message, 'Olá!');
      expect(model.isRead, false);
    });

    test('toEntity sets isFromCurrentUser true when senderId matches', () {
      final entity = ChatMessageModel.fromJson(json).toEntity('client-1');
      expect(entity.isFromCurrentUser, true);
    });

    test('toEntity sets isFromCurrentUser false for other sender', () {
      final entity = ChatMessageModel.fromJson(json).toEntity('driver-user-1');
      expect(entity.isFromCurrentUser, false);
    });
  });
}
```

- [ ] **Step 2: Rodar o teste para confirmar falha**

```
flutter test test/features/chat/data/models/chat_models_test.dart
```

Esperado: FAIL — `ChatRoomModel` não definido.

- [ ] **Step 3: Criar `chat_room_model.dart`**

```dart
// lib/features/chat/data/models/chat_room_model.dart
import 'package:kz_servicos_app/features/chat/domain/entities/chat_room.dart';

class ChatRoomModel {
  const ChatRoomModel({
    required this.id,
    required this.tripId,
    required this.clientId,
    required this.providerId,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String tripId;
  final String clientId;
  final String providerId;
  final bool isActive;
  final DateTime createdAt;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      clientId: json['client_id'] as String,
      providerId: json['provider_id'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  ChatRoom toEntity() => ChatRoom(
        id: id,
        tripId: tripId,
        clientId: clientId,
        providerId: providerId,
        isActive: isActive,
        createdAt: createdAt,
      );
}
```

- [ ] **Step 4: Criar `chat_message_model.dart`**

```dart
// lib/features/chat/data/models/chat_message_model.dart
import 'package:kz_servicos_app/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String chatRoomId;
  final String senderId;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      chatRoomId: json['chat_room_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  ChatMessage toEntity(String currentUserId) => ChatMessage(
        id: id,
        chatRoomId: chatRoomId,
        senderId: senderId,
        message: message,
        isFromCurrentUser: senderId == currentUserId,
        createdAt: createdAt,
        isRead: isRead,
      );
}
```

- [ ] **Step 5: Rodar o teste para confirmar aprovação**

```
flutter test test/features/chat/data/models/chat_models_test.dart
```

Esperado: PASS — todos os testes verdes.

- [ ] **Step 6: Commit**

```
git add lib/features/chat/data/models/ test/features/chat/data/
git commit -m "feat(chat): add ChatRoomModel and ChatMessageModel with tests"
```

---

## Task 4: TripRepositoryImpl — getChatEligibleTrips

**Files:**
- Modify: `lib/features/trip/data/repositories/trip_repository_impl.dart`

- [ ] **Step 1: Adicionar `_chatEligibleStatuses` e o método em `trip_repository_impl.dart`**

No final do arquivo, antes do último `}` da classe, adicionar:

```dart
  static const _chatEligibleStatuses = ['scheduled', 'started', 'finished'];

  @override
  Future<List<ScheduledTrip>> getChatEligibleTrips(String clientId) async {
    final response = await _client
        .from('trips')
        .select(
          '*, '
          'pickup_address:addresses!pickup_address_id(*), '
          'dropoff_address:addresses!dropoff_address_id(*), '
          'driver_profiles(provider_profiles(users(full_name)))',
        )
        .eq('client_id', clientId)
        .inFilter('status', _chatEligibleStatuses)
        .order('scheduled_datetime', ascending: false);

    return response
        .map((json) => ScheduledTripModel.fromJson(json).toEntity())
        .toList();
  }
```

- [ ] **Step 2: Verificar análise estática**

```
flutter analyze lib/features/trip/data/repositories/trip_repository_impl.dart
```

Esperado: zero erros.

- [ ] **Step 3: Commit**

```
git add lib/features/trip/data/repositories/trip_repository_impl.dart
git commit -m "feat(chat): implement getChatEligibleTrips in TripRepositoryImpl"
```

---

## Task 5: ChatRepositoryImpl

**Files:**
- Create: `lib/features/chat/data/repositories/chat_repository_impl.dart`

- [ ] **Step 1: Criar `chat_repository_impl.dart`**

```dart
// lib/features/chat/data/repositories/chat_repository_impl.dart
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kz_servicos_app/features/chat/data/models/chat_message_model.dart';
import 'package:kz_servicos_app/features/chat/data/models/chat_room_model.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_message.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_room.dart';
import 'package:kz_servicos_app/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  String get _currentUserId => _client.auth.currentUser!.id;

  @override
  Future<ChatRoom> getOrCreateRoomForTrip(String tripId) async {
    final existing = await _client
        .from('chat_rooms')
        .select()
        .eq('trip_id', tripId)
        .maybeSingle();

    if (existing != null) {
      return ChatRoomModel.fromJson(existing).toEntity();
    }

    final tripRow = await _client
        .from('trips')
        .select(
          'client_id, '
          'driver_profiles(provider_profiles(user_id))',
        )
        .eq('id', tripId)
        .single();

    final driverProfiles =
        tripRow['driver_profiles'] as Map<String, dynamic>?;
    final providerProfiles =
        driverProfiles?['provider_profiles'] as Map<String, dynamic>?;
    final driverUserId = providerProfiles?['user_id'] as String?;

    if (driverUserId == null) {
      throw Exception(
        'Viagem $tripId não tem motorista — impossível criar sala de chat.',
      );
    }

    final inserted = await _client
        .from('chat_rooms')
        .insert({
          'trip_id': tripId,
          'client_id': tripRow['client_id'] as String,
          'provider_id': driverUserId,
        })
        .select()
        .single();

    return ChatRoomModel.fromJson(inserted).toEntity();
  }

  @override
  Future<List<ChatMessage>> getMessages(String chatRoomId) async {
    final response = await _client
        .from('chat_messages')
        .select()
        .eq('chat_room_id', chatRoomId)
        .order('created_at');

    return response
        .map((json) => ChatMessageModel.fromJson(json).toEntity(_currentUserId))
        .toList();
  }

  @override
  Future<ChatMessage> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String text,
  }) async {
    final inserted = await _client
        .from('chat_messages')
        .insert({
          'chat_room_id': chatRoomId,
          'sender_id': senderId,
          'message': text,
          'message_type': 'text',
        })
        .select()
        .single();

    return ChatMessageModel.fromJson(inserted).toEntity(_currentUserId);
  }

  @override
  Stream<ChatMessage> subscribeToMessages(String chatRoomId) {
    late final RealtimeChannel channel;
    late final StreamController<ChatMessage> controller;

    controller = StreamController<ChatMessage>.broadcast(
      onCancel: () => _client.removeChannel(channel),
    );

    channel = _client
        .channel('chat-room-$chatRoomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_room_id',
            value: chatRoomId,
          ),
          callback: (payload) {
            if (!controller.isClosed) {
              controller.add(
                ChatMessageModel.fromJson(payload.newRecord)
                    .toEntity(_currentUserId),
              );
            }
          },
        )
        .subscribe();

    return controller.stream;
  }

  @override
  Future<void> markAllAsRead(String chatRoomId, String userId) async {
    await _client
        .from('chat_messages')
        .update({
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        })
        .eq('chat_room_id', chatRoomId)
        .eq('is_read', false)
        .neq('sender_id', userId);
  }

  @override
  Future<Map<String, ChatRoom?>> getRoomsForTrips(
    List<String> tripIds,
  ) async {
    if (tripIds.isEmpty) return {};

    final response = await _client
        .from('chat_rooms')
        .select()
        .inFilter('trip_id', tripIds);

    final result = <String, ChatRoom?>{for (final id in tripIds) id: null};
    for (final json in response) {
      final room = ChatRoomModel.fromJson(json).toEntity();
      result[room.tripId] = room;
    }
    return result;
  }

  @override
  Future<Map<String, ChatMessage?>> getLastMessages(
    List<String> roomIds,
  ) async {
    if (roomIds.isEmpty) return {};

    final response = await _client
        .from('chat_messages')
        .select()
        .inFilter('chat_room_id', roomIds)
        .order('created_at', ascending: false);

    final result = <String, ChatMessage?>{for (final id in roomIds) id: null};
    for (final json in response) {
      final msg = ChatMessageModel.fromJson(json).toEntity(_currentUserId);
      // putIfAbsent mantém apenas a mais recente por sala (já ordenado desc)
      result.putIfAbsent(msg.chatRoomId, () => msg);
    }
    return result;
  }

  @override
  Future<Map<String, int>> getUnreadCounts(
    List<String> roomIds,
    String currentUserId,
  ) async {
    if (roomIds.isEmpty) return {};

    final response = await _client
        .from('chat_messages')
        .select('chat_room_id')
        .inFilter('chat_room_id', roomIds)
        .eq('is_read', false)
        .neq('sender_id', currentUserId);

    final counts = <String, int>{for (final id in roomIds) id: 0};
    for (final json in response) {
      final roomId = json['chat_room_id'] as String;
      counts[roomId] = (counts[roomId] ?? 0) + 1;
    }
    return counts;
  }
}
```

- [ ] **Step 2: Verificar análise estática**

```
flutter analyze lib/features/chat/data/repositories/
```

Esperado: zero erros.

- [ ] **Step 3: Commit**

```
git add lib/features/chat/data/repositories/
git commit -m "feat(chat): implement ChatRepositoryImpl with Supabase and Realtime"
```

---

## Task 6: MessagesState + MessagesCubit

**Files:**
- Create: `lib/features/chat/presentation/cubit/messages_state.dart`
- Create: `lib/features/chat/presentation/cubit/messages_cubit.dart`
- Create: `test/features/chat/presentation/cubit/messages_cubit_test.dart`

- [ ] **Step 1: Criar `messages_state.dart`**

```dart
// lib/features/chat/presentation/cubit/messages_state.dart
import 'package:equatable/equatable.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_message.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_room.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/scheduled_trip.dart';

abstract class MessagesState extends Equatable {
  const MessagesState();
  @override
  List<Object?> get props => [];
}

class MessagesInitial extends MessagesState {
  const MessagesInitial();
}

class MessagesLoading extends MessagesState {
  const MessagesLoading();
}

class MessagesLoaded extends MessagesState {
  const MessagesLoaded({
    required this.trips,
    required this.rooms,
    required this.lastMessages,
    required this.unreadCounts,
  });

  final List<ScheduledTrip> trips;
  final Map<String, ChatRoom?> rooms;
  final Map<String, ChatMessage?> lastMessages;
  final Map<String, int> unreadCounts;

  @override
  List<Object?> get props => [trips, rooms, lastMessages, unreadCounts];
}

class MessagesError extends MessagesState {
  const MessagesError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
```

- [ ] **Step 2: Escrever o teste com falha esperada**

```dart
// test/features/chat/presentation/cubit/messages_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_message.dart';
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
```

- [ ] **Step 3: Rodar teste para confirmar falha**

```
flutter test test/features/chat/presentation/cubit/messages_cubit_test.dart
```

Esperado: FAIL — `MessagesCubit` não definido.

- [ ] **Step 4: Criar `messages_cubit.dart`**

Notar que o cubit recebe `clientId` como parâmetro (em vez de chamar `Supabase.instance.client.auth` diretamente), o que facilita os testes.

```dart
// lib/features/chat/presentation/cubit/messages_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_message.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_room.dart';
import 'package:kz_servicos_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/messages_state.dart';
import 'package:kz_servicos_app/features/trip/domain/repositories/trip_repository.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit({
    required TripRepository tripRepository,
    required ChatRepository chatRepository,
    required String clientId,
  })  : _tripRepository = tripRepository,
        _chatRepository = chatRepository,
        _clientId = clientId,
        super(const MessagesInitial());

  final TripRepository _tripRepository;
  final ChatRepository _chatRepository;
  final String _clientId;

  Future<void> load() async {
    emit(const MessagesLoading());
    try {
      final trips = await _tripRepository.getChatEligibleTrips(_clientId);

      if (trips.isEmpty) {
        emit(const MessagesLoaded(
          trips: [],
          rooms: {},
          lastMessages: {},
          unreadCounts: {},
        ));
        return;
      }

      final tripIds = trips.map((t) => t.id).toList(growable: false);
      final rooms = await _chatRepository.getRoomsForTrips(tripIds);

      final roomIds = rooms.values
          .whereType<ChatRoom>()
          .map((r) => r.id)
          .toList(growable: false);

      Map<String, ChatMessage?> lastMessages = {};
      Map<String, int> unreadCounts = {};

      if (roomIds.isNotEmpty) {
        lastMessages = await _chatRepository.getLastMessages(roomIds);
        unreadCounts =
            await _chatRepository.getUnreadCounts(roomIds, _clientId);
      }

      emit(MessagesLoaded(
        trips: trips,
        rooms: rooms,
        lastMessages: lastMessages,
        unreadCounts: unreadCounts,
      ));
    } on Exception catch (e) {
      emit(MessagesError(e.toString()));
    }
  }
}
```

- [ ] **Step 5: Rodar teste para confirmar aprovação**

```
flutter test test/features/chat/presentation/cubit/messages_cubit_test.dart
```

Esperado: PASS — todos os testes verdes.

- [ ] **Step 6: Commit**

```
git add lib/features/chat/presentation/cubit/messages_state.dart lib/features/chat/presentation/cubit/messages_cubit.dart test/features/chat/presentation/cubit/messages_cubit_test.dart
git commit -m "feat(chat): add MessagesCubit and MessagesState with tests"
```

---

## Task 7: ChatState + ChatCubit

**Files:**
- Create: `lib/features/chat/presentation/cubit/chat_state.dart`
- Create: `lib/features/chat/presentation/cubit/chat_cubit.dart`
- Create: `test/features/chat/presentation/cubit/chat_cubit_test.dart`

- [ ] **Step 1: Criar `chat_state.dart`**

```dart
// lib/features/chat/presentation/cubit/chat_state.dart
import 'package:equatable/equatable.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_message.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_room.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  const ChatLoaded({
    required this.room,
    required this.messages,
    this.isSending = false,
    this.tripOrigin,
    this.tripDestination,
  });

  final ChatRoom room;
  final List<ChatMessage> messages;
  final bool isSending;
  final String? tripOrigin;
  final String? tripDestination;

  ChatLoaded copyWith({
    ChatRoom? room,
    List<ChatMessage>? messages,
    bool? isSending,
    String? tripOrigin,
    String? tripDestination,
  }) =>
      ChatLoaded(
        room: room ?? this.room,
        messages: messages ?? this.messages,
        isSending: isSending ?? this.isSending,
        tripOrigin: tripOrigin ?? this.tripOrigin,
        tripDestination: tripDestination ?? this.tripDestination,
      );

  @override
  List<Object?> get props =>
      [room, messages, isSending, tripOrigin, tripDestination];
}

class ChatError extends ChatState {
  const ChatError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
```

- [ ] **Step 2: Escrever o teste com falha esperada**

```dart
// test/features/chat/presentation/cubit/chat_cubit_test.dart
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
```

- [ ] **Step 3: Rodar teste para confirmar falha**

```
flutter test test/features/chat/presentation/cubit/chat_cubit_test.dart
```

Esperado: FAIL — `ChatCubit` não definido.

- [ ] **Step 4: Criar `chat_cubit.dart`**

```dart
// lib/features/chat/presentation/cubit/chat_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_message.dart';
import 'package:kz_servicos_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required ChatRepository chatRepository,
    required String currentUserId,
  })  : _chatRepository = chatRepository,
        _currentUserId = currentUserId,
        super(const ChatInitial());

  final ChatRepository _chatRepository;
  final String _currentUserId;
  StreamSubscription<ChatMessage>? _subscription;

  Future<void> init(
    String tripId, {
    String? tripOrigin,
    String? tripDestination,
  }) async {
    emit(const ChatLoading());
    try {
      final room = await _chatRepository.getOrCreateRoomForTrip(tripId);
      final messages = await _chatRepository.getMessages(room.id);
      await _chatRepository.markAllAsRead(room.id, _currentUserId);

      emit(ChatLoaded(
        room: room,
        messages: messages,
        tripOrigin: tripOrigin,
        tripDestination: tripDestination,
      ));

      _subscription = _chatRepository
          .subscribeToMessages(room.id)
          .listen(_onRealtimeMessage);
    } on Exception catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onRealtimeMessage(ChatMessage message) {
    final current = state;
    if (current is! ChatLoaded) return;

    final exists = current.messages.any((m) => m.id == message.id);
    if (exists) {
      emit(current.copyWith(
        messages: current.messages
            .map((m) => m.id == message.id ? message : m)
            .toList(),
      ));
    } else {
      emit(current.copyWith(
        messages: [...current.messages, message],
      ));
    }
  }

  Future<void> sendMessage(String text) async {
    final current = state;
    if (current is! ChatLoaded || text.trim().isEmpty) return;

    final trimmed = text.trim();
    final optimisticId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = ChatMessage(
      id: optimisticId,
      chatRoomId: current.room.id,
      senderId: _currentUserId,
      message: trimmed,
      isFromCurrentUser: true,
      createdAt: DateTime.now(),
      isRead: false,
    );

    emit(current.copyWith(
      messages: [...current.messages, optimistic],
      isSending: true,
    ));

    try {
      await _chatRepository.sendMessage(
        chatRoomId: current.room.id,
        senderId: _currentUserId,
        text: trimmed,
      );
      // Realtime entregará a mensagem confirmada, substituindo a otimista
      if (state is ChatLoaded) {
        emit((state as ChatLoaded).copyWith(isSending: false));
      }
    } on Exception {
      if (state is ChatLoaded) {
        final loaded = state as ChatLoaded;
        emit(loaded.copyWith(
          messages:
              loaded.messages.where((m) => m.id != optimisticId).toList(),
          isSending: false,
        ));
      }
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
```

- [ ] **Step 5: Rodar teste para confirmar aprovação**

```
flutter test test/features/chat/presentation/cubit/chat_cubit_test.dart
```

Esperado: PASS — todos os testes verdes.

- [ ] **Step 6: Rodar todos os testes para confirmar nada quebrou**

```
flutter test
```

Esperado: PASS em todos.

- [ ] **Step 7: Commit**

```
git add lib/features/chat/presentation/cubit/chat_state.dart lib/features/chat/presentation/cubit/chat_cubit.dart test/features/chat/presentation/cubit/chat_cubit_test.dart
git commit -m "feat(chat): add ChatCubit and ChatState with Realtime support and tests"
```

---

## Task 8: TripDetailsSheet — botão "Abrir chat"

**Files:**
- Modify: `lib/features/trip/presentation/widgets/trip_details_sheet.dart`

- [ ] **Step 1: Adicionar import de `go_router` se não presente e adicionar o botão**

Abrir `lib/features/trip/presentation/widgets/trip_details_sheet.dart`. Adicionar o import no topo (após os imports existentes):

```dart
import 'package:go_router/go_router.dart';
```

Localizar o `Column` principal no `build`. Após o `Padding` do card de informações e antes do `SizedBox` de padding inferior, inserir:

```dart
          if (['scheduled', 'started', 'finished'].contains(trip.status)) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                  label: const Text(
                    'Abrir chat com motorista',
                    style: TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/chat/${trip.id}', extra: trip);
                  },
                ),
              ),
            ),
          ],
```

O `build` completo após as mudanças:

```dart
  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = _statusColors;

    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Detalhes da Viagem',
            style: TextStyle(
              fontFamily: 'OutfitBlack',
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MapRoutePreview(
              originLat: trip.originLat,
              originLng: trip.originLng,
              destinationLat: trip.destinationLat,
              destinationLng: trip.destinationLng,
              height: 150,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        fontFamily: 'QuasimodoSemiBold',
                        fontSize: 12,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.circle,
                    iconColor: AppColors.secondary,
                    iconSize: 8,
                    label: trip.origin,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.circle,
                    iconColor: AppColors.highlight,
                    iconSize: 8,
                    label: trip.destination,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                  ),
                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    iconColor: AppColors.textPrimary.withValues(alpha: 0.6),
                    label: _formatDate(trip.scheduledDatetime),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.people_rounded,
                    iconColor: AppColors.textPrimary.withValues(alpha: 0.6),
                    label:
                        '${trip.passengerCount} passageiro${trip.passengerCount > 1 ? 's' : ''}',
                  ),
                  if (trip.driverName != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.person_rounded,
                      iconColor:
                          AppColors.textPrimary.withValues(alpha: 0.6),
                      label: trip.driverName!,
                    ),
                  ],
                  if (trip.observations != null &&
                      trip.observations!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.notes_rounded,
                      iconColor:
                          AppColors.textPrimary.withValues(alpha: 0.6),
                      label: trip.observations!,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (['scheduled', 'started', 'finished'].contains(trip.status)) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                  label: const Text(
                    'Abrir chat com motorista',
                    style: TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/chat/${trip.id}', extra: trip);
                  },
                ),
              ),
            ),
          ],
          SizedBox(
            height: MediaQuery.of(context).padding.bottom + 24,
          ),
        ],
      ),
    );
  }
```

- [ ] **Step 2: Verificar análise estática**

```
flutter analyze lib/features/trip/presentation/widgets/trip_details_sheet.dart
```

Esperado: zero erros.

- [ ] **Step 3: Commit**

```
git add lib/features/trip/presentation/widgets/trip_details_sheet.dart
git commit -m "feat(chat): add open-chat button to TripDetailsSheet for eligible trips"
```

---

## Task 9: AppRouter — atualizar rotas e BlocProviders

**Files:**
- Modify: `lib/routes/app_router.dart`

- [ ] **Step 1: Adicionar imports necessários em `app_router.dart`**

No topo do arquivo, adicionar após os imports existentes:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kz_servicos_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/messages_cubit.dart';
import 'package:kz_servicos_app/features/trip/data/repositories/trip_repository_impl.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/scheduled_trip.dart';
```

- [ ] **Step 2: Substituir as rotas `/messages` e `/chat/:conversationId`**

Localizar e substituir:

```dart
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagesPage(),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) => ChatPage(
          conversationId: state.pathParameters['conversationId']!,
        ),
      ),
```

Por:

```dart
      GoRoute(
        path: '/messages',
        builder: (context, state) {
          final client = Supabase.instance.client;
          final clientId = client.auth.currentUser!.id;
          return BlocProvider(
            create: (_) => MessagesCubit(
              tripRepository: TripRepositoryImpl(client: client),
              chatRepository: ChatRepositoryImpl(client: client),
              clientId: clientId,
            )..load(),
            child: const MessagesPage(),
          );
        },
      ),
      GoRoute(
        path: '/chat/:tripId',
        builder: (context, state) {
          final client = Supabase.instance.client;
          final tripId = state.pathParameters['tripId']!;
          final trip = state.extra as ScheduledTrip?;
          return BlocProvider(
            create: (_) => ChatCubit(
              chatRepository: ChatRepositoryImpl(client: client),
              currentUserId: client.auth.currentUser!.id,
            )..init(
                tripId,
                tripOrigin: trip?.origin,
                tripDestination: trip?.destination,
              ),
            child: const ChatPage(),
          );
        },
      ),
```

- [ ] **Step 3: Verificar análise estática**

```
flutter analyze lib/routes/app_router.dart
```

Esperado: zero erros. Se aparecer erro no `ChatPage` (construtor), será resolvido na Task 10.

- [ ] **Step 4: Commit**

```
git add lib/routes/app_router.dart
git commit -m "feat(chat): update router - /chat/:tripId with inline BlocProviders"
```

---

## Task 10: MessagesPage — conectar à API

**Files:**
- Modify: `lib/features/profile/presentation/pages/messages_page.dart`

- [ ] **Step 1: Reescrever `messages_page.dart`**

Substituir o conteúdo completo do arquivo:

```dart
// lib/features/profile/presentation/pages/messages_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_message.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/messages_cubit.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/messages_state.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/scheduled_trip.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 8),
          _buildHeader(context),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<MessagesCubit, MessagesState>(
              builder: (context, state) {
                if (state is MessagesLoading || state is MessagesInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MessagesError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar mensagens',
                      style: TextStyle(
                        fontFamily: 'QuasimodoSemiBold',
                        fontSize: 16,
                        color: Colors.red.shade400,
                      ),
                    ),
                  );
                }
                if (state is MessagesLoaded) {
                  if (state.trips.isEmpty) return _buildEmptyState();
                  return _buildList(context, state);
                }
                return const SizedBox.shrink();
              },
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
              'Mensagens',
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: Color(0xFFBDBDBD),
          ),
          SizedBox(height: 16),
          Text(
            'Nenhuma mensagem',
            style: TextStyle(
              fontFamily: 'QuasimodoSemiBold',
              fontSize: 16,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, MessagesLoaded state) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: state.trips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trip = state.trips[index];
        final room = state.rooms[trip.id];
        final lastMsg =
            room != null ? state.lastMessages[room.id] : null;
        final unread =
            room != null ? (state.unreadCounts[room.id] ?? 0) : 0;
        return _ConversationTile(
          trip: trip,
          lastMessage: lastMsg,
          unreadCount: unread,
          onTap: () => context.push('/chat/${trip.id}', extra: trip),
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.trip,
    required this.onTap,
    this.lastMessage,
    this.unreadCount = 0,
  });

  final ScheduledTrip trip;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final VoidCallback onTap;

  String get _preview {
    if (lastMessage == null) return '';
    return lastMessage!.isFromCurrentUser
        ? 'Você: ${lastMessage!.message}'
        : lastMessage!.message;
  }

  String get _timeLabel {
    if (lastMessage == null) return '';
    final diff = DateTime.now().difference(lastMessage!.createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${lastMessage!.createdAt.day}/${lastMessage!.createdAt.month}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppColors.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'KZ Serviços',
                          style: TextStyle(
                            fontFamily: 'OutfitBlack',
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (_timeLabel.isNotEmpty)
                        Text(
                          _timeLabel,
                          style: const TextStyle(
                            fontFamily: 'QuasimodoSemiBold',
                            fontSize: 11,
                            color: Color(0xFF999999),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${trip.origin} → ${trip.destination}',
                    style: const TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _preview,
                          style: TextStyle(
                            fontFamily: 'QuasimodoSemiBold',
                            fontSize: 12,
                            color: unreadCount > 0
                                ? AppColors.textPrimary
                                : const Color(0xFF999999),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.highlight,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              fontFamily: 'OutfitBlack',
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
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
```

- [ ] **Step 2: Verificar análise estática**

```
flutter analyze lib/features/profile/presentation/pages/messages_page.dart
```

Esperado: zero erros.

- [ ] **Step 3: Commit**

```
git add lib/features/profile/presentation/pages/messages_page.dart
git commit -m "feat(chat): connect MessagesPage to API via MessagesCubit"
```

---

## Task 11: ChatPage — conectar à API

**Files:**
- Modify: `lib/features/profile/presentation/pages/chat_page.dart`

- [ ] **Step 1: Reescrever `chat_page.dart`**

Substituir o conteúdo completo do arquivo:

```dart
// lib/features/profile/presentation/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_message.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/chat_state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const _presetMessages = [
    'Estou chegando',
    'Vou me atrasar',
    'Pode confirmar o endereço?',
    'Obrigado(a)!',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    context.read<ChatCubit>().sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) _scrollToBottom();
        },
        builder: (context, state) {
          if (state is ChatLoading || state is ChatInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChatError) {
            return Center(
              child: Text(
                'Erro ao carregar chat: ${state.message}',
                style: TextStyle(
                  fontFamily: 'QuasimodoSemiBold',
                  fontSize: 14,
                  color: Colors.red.shade400,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }
          if (state is ChatLoaded) {
            return Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 8),
                _buildHeader(context, state),
                Expanded(child: _buildMessagesList(state.messages)),
                _buildPresetBar(),
                _buildInputBar(context, state.isSending),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatLoaded state) {
    final subtitle = (state.tripOrigin != null && state.tripDestination != null)
        ? '${state.tripOrigin} → ${state.tripDestination}'
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KZ Serviços',
                  style: TextStyle(
                    fontFamily: 'OutfitBlack',
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 11,
                      color: Color(0xFF999999),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return _MessageBubble(message: messages[index]);
      },
    );
  }

  Widget _buildPresetBar() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _presetMessages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _sendMessage(_presetMessages[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Text(
                _presetMessages[index],
                style: const TextStyle(
                  fontFamily: 'QuasimodoSemiBold',
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, bool isSending) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                enabled: !isSending,
                decoration: const InputDecoration(
                  hintText: 'Digite uma mensagem...',
                  hintStyle: TextStyle(
                    fontFamily: 'QuasimodoSemiBold',
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(
                  fontFamily: 'QuasimodoSemiBold',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isSending ? null : () => _sendMessage(_messageController.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSending
                    ? AppColors.secondary.withValues(alpha: 0.5)
                    : AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isFromCurrentUser;
    final hour = message.createdAt.hour.toString().padLeft(2, '0');
    final minute = message.createdAt.minute.toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppColors.secondary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.secondary : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 13,
                      color: isUser ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$hour:$minute',
                    style: TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 10,
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.7)
                          : const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verificar análise estática**

```
flutter analyze lib/features/profile/presentation/pages/chat_page.dart
```

Esperado: zero erros.

- [ ] **Step 3: Rodar todos os testes**

```
flutter test
```

Esperado: PASS em todos.

- [ ] **Step 4: Commit**

```
git add lib/features/profile/presentation/pages/chat_page.dart
git commit -m "feat(chat): connect ChatPage to API via ChatCubit with Realtime"
```

---

## Task 12: Verificação final e análise completa

- [ ] **Step 1: Rodar análise estática completa**

```
flutter analyze
```

Esperado: zero erros. Se houver warnings sobre `import` não usados (ex.: `mock_message.dart`), removê-los dos arquivos que foram reescritos.

- [ ] **Step 2: Remover import de mock não mais usado**

Se `flutter analyze` reportar import de `mock_message.dart` não utilizado em algum arquivo (não deve ocorrer pois os arquivos foram completamente reescritos), removê-lo.

- [ ] **Step 3: Rodar todos os testes**

```
flutter test
```

Esperado: PASS em todos.

- [ ] **Step 4: Commit final**

```
git add .
git commit -m "feat(chat): complete messaging feature - ChatPage, MessagesPage, TripDetailsSheet"
```
