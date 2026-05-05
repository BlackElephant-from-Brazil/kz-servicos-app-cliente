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
