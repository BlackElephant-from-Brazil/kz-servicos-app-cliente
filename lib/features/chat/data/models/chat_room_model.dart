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
