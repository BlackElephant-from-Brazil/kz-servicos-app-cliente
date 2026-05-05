import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_message.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_room.dart';
import 'package:kz_servicos_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/messages_state.dart';
import 'package:kz_servicos_app/features/trip/domain/repositories/trip_repository.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit({
    required TripRepository tripRepository,
    required ChatRepository chatRepository,
    required String clientId,
  })  : _tripRepository = tripRepository,
        _chatRepository = chatRepository,
        _clientId = clientId,
        super(const MessagesInitial());

  final TripRepository _tripRepository;
  final ChatRepository _chatRepository;
  final String _clientId;

  Future<void> load() async {
    emit(const MessagesLoading());
    try {
      final trips = await _tripRepository.getChatEligibleTrips(_clientId);

      if (trips.isEmpty) {
        emit(const MessagesLoaded(
          trips: [],
          rooms: {},
          lastMessages: {},
          unreadCounts: {},
        ));
        return;
      }

      final tripIds = trips.map((t) => t.id).toList(growable: false);
      final rooms = await _chatRepository.getRoomsForTrips(tripIds);

      final roomIds = rooms.values
          .whereType<ChatRoom>()
          .map((r) => r.id)
          .toList(growable: false);

      Map<String, ChatMessage?> lastMessages = {};
      Map<String, int> unreadCounts = {};

      if (roomIds.isNotEmpty) {
        lastMessages = await _chatRepository.getLastMessages(roomIds);
        unreadCounts =
            await _chatRepository.getUnreadCounts(roomIds, _clientId);
      }

      emit(MessagesLoaded(
        trips: trips,
        rooms: rooms,
        lastMessages: lastMessages,
        unreadCounts: unreadCounts,
      ));
    } on Exception catch (e) {
      emit(MessagesError(e.toString()));
    }
  }
}
