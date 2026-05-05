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
