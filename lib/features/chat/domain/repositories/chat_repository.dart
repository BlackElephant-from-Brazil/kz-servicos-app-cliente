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

  /// Retorna salas para múltiplos trips (Map&lt;tripId, ChatRoom?&gt;).
  /// trips sem sala mapeiam para null.
  Future<Map<String, ChatRoom?>> getRoomsForTrips(List<String> tripIds);

  /// Última mensagem por sala (Map&lt;roomId, ChatMessage?&gt;).
  Future<Map<String, ChatMessage?>> getLastMessages(List<String> roomIds);

  /// Contagem de não-lidos por sala para o usuário atual.
  Future<Map<String, int>> getUnreadCounts(
    List<String> roomIds,
    String currentUserId,
  );
}
