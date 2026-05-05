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
