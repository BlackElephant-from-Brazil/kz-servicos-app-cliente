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
