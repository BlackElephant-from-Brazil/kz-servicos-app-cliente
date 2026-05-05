import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_message.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/messages_cubit.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/messages_state.dart';
import 'package:kz_servicos_app/features/trip/domain/entities/scheduled_trip.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 8),
          _buildHeader(context),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<MessagesCubit, MessagesState>(
              builder: (context, state) {
                if (state is MessagesLoading || state is MessagesInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MessagesError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar mensagens',
                      style: TextStyle(
                        fontFamily: 'QuasimodoSemiBold',
                        fontSize: 16,
                        color: Colors.red.shade400,
                      ),
                    ),
                  );
                }
                if (state is MessagesLoaded) {
                  if (state.trips.isEmpty) return _buildEmptyState();
                  return _buildList(context, state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 22,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Mensagens',
              style: TextStyle(
                fontFamily: 'OutfitBlack',
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: Color(0xFFBDBDBD),
          ),
          SizedBox(height: 16),
          Text(
            'Nenhuma mensagem',
            style: TextStyle(
              fontFamily: 'QuasimodoSemiBold',
              fontSize: 16,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, MessagesLoaded state) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: state.trips.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trip = state.trips[index];
        final room = state.rooms[trip.id];
        final lastMsg =
            room != null ? state.lastMessages[room.id] : null;
        final unread =
            room != null ? (state.unreadCounts[room.id] ?? 0) : 0;
        return _ConversationTile(
          trip: trip,
          lastMessage: lastMsg,
          unreadCount: unread,
          onTap: () => context.push('/chat/${trip.id}', extra: trip),
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.trip,
    required this.onTap,
    this.lastMessage,
    this.unreadCount = 0,
  });

  final ScheduledTrip trip;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final VoidCallback onTap;

  String get _preview {
    if (lastMessage == null) return '';
    return lastMessage!.isFromCurrentUser
        ? 'Você: ${lastMessage!.message}'
        : lastMessage!.message;
  }

  String get _timeLabel {
    if (lastMessage == null) return '';
    final diff = DateTime.now().difference(lastMessage!.createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${lastMessage!.createdAt.day}/${lastMessage!.createdAt.month}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppColors.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'KZ Serviços',
                          style: TextStyle(
                            fontFamily: 'OutfitBlack',
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (_timeLabel.isNotEmpty)
                        Text(
                          _timeLabel,
                          style: const TextStyle(
                            fontFamily: 'QuasimodoSemiBold',
                            fontSize: 11,
                            color: Color(0xFF999999),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${trip.origin} → ${trip.destination}',
                    style: const TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _preview,
                          style: TextStyle(
                            fontFamily: 'QuasimodoSemiBold',
                            fontSize: 12,
                            color: unreadCount > 0
                                ? AppColors.textPrimary
                                : const Color(0xFF999999),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.highlight,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              fontFamily: 'OutfitBlack',
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
