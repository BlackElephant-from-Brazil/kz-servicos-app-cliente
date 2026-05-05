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
      // Remove the optimistic message — Realtime will deliver the confirmed one
      if (state is ChatLoaded) {
        final loaded = state as ChatLoaded;
        emit(loaded.copyWith(
          messages: loaded.messages.where((m) => m.id != optimisticId).toList(),
          isSending: false,
        ));
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
