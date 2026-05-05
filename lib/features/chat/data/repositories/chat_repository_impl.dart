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
