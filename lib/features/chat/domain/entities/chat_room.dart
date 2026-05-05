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
