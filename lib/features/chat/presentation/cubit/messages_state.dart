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
