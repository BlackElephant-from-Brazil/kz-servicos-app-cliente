import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_servicos_app/core/constants/app_colors.dart';
import 'package:kz_servicos_app/features/chat/domain/entities/chat_message.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:kz_servicos_app/features/chat/presentation/cubit/chat_state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const _presetMessages = [
    'Estou chegando',
    'Vou me atrasar',
    'Pode confirmar o endereço?',
    'Obrigado(a)!',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    context.read<ChatCubit>().sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) _scrollToBottom();
        },
        builder: (context, state) {
          if (state is ChatLoading || state is ChatInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChatError) {
            return Center(
              child: Text(
                'Erro ao carregar chat: ${state.message}',
                style: TextStyle(
                  fontFamily: 'QuasimodoSemiBold',
                  fontSize: 14,
                  color: Colors.red.shade400,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }
          if (state is ChatLoaded) {
            return Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 8),
                _buildHeader(context, state),
                Expanded(child: _buildMessagesList(state.messages)),
                _buildPresetBar(),
                _buildInputBar(context, state.isSending),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatLoaded state) {
    final subtitle = (state.tripOrigin != null && state.tripDestination != null)
        ? '${state.tripOrigin} → ${state.tripDestination}'
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KZ Serviços',
                  style: TextStyle(
                    fontFamily: 'OutfitBlack',
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 11,
                      color: Color(0xFF999999),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return _MessageBubble(message: messages[index]);
      },
    );
  }

  Widget _buildPresetBar() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _presetMessages.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _sendMessage(_presetMessages[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Text(
                _presetMessages[index],
                style: const TextStyle(
                  fontFamily: 'QuasimodoSemiBold',
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, bool isSending) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                enabled: !isSending,
                decoration: const InputDecoration(
                  hintText: 'Digite uma mensagem...',
                  hintStyle: TextStyle(
                    fontFamily: 'QuasimodoSemiBold',
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(
                  fontFamily: 'QuasimodoSemiBold',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isSending ? null : () => _sendMessage(_messageController.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSending
                    ? AppColors.secondary.withValues(alpha: 0.5)
                    : AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isFromCurrentUser;
    final hour = message.createdAt.hour.toString().padLeft(2, '0');
    final minute = message.createdAt.minute.toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppColors.secondary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.secondary : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 13,
                      color: isUser ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$hour:$minute',
                    style: TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 10,
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.7)
                          : const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
