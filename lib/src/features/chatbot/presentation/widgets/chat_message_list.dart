import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_controller.dart';
import 'chat_message_bubble.dart';
import 'thinking_trace_panel.dart';

class ChatMessageList extends ConsumerStatefulWidget {
  final String sessionId;
  final ValueChanged<String> onSendChip;

  const ChatMessageList({
    super.key,
    required this.sessionId,
    required this.onSendChip,
  });

  @override
  ConsumerState<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends ConsumerState<ChatMessageList> {
  final _scrollController = ScrollController();
  Timer? _streamTimer;
  int _streamDisplayCount = 0;
  bool _autoScroll = true;
  String _streamedFullContent = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isNearBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100;
    if (_autoScroll != isNearBottom) {
      setState(() => _autoScroll = isNearBottom);
    }
  }

  void _scrollToBottom() {
    if (!_autoScroll || !_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startStreaming(String fullContent) {
    _streamDisplayCount = 0;
    _streamedFullContent = fullContent;
    final interval = Duration(
      milliseconds: (1000 / 80).round().clamp(10, 200),
    );
    _streamTimer = Timer.periodic(interval, (_) {
      if (!mounted) {
        _streamTimer?.cancel();
        return;
      }
      setState(() {
        _streamDisplayCount += 2;
        if (_streamDisplayCount >= _streamedFullContent.length) {
          _streamDisplayCount = _streamedFullContent.length;
          _streamTimer?.cancel();
          _streamTimer = null;
          ref.read(chatControllerProvider.notifier).completeStreaming();
        }
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(chatControllerProvider, (prev, next) {
      if (prev?.phase != ChatProcessingPhase.streaming &&
          next.phase == ChatProcessingPhase.streaming &&
          next.fullContent != null) {
        _startStreaming(next.fullContent!);
      }
      if (prev?.phase != ChatProcessingPhase.idle &&
          next.phase == ChatProcessingPhase.idle) {
        _scrollToBottom();
      }
    });

    final messagesAsync = ref.watch(messagesProvider(widget.sessionId));
    final procState = ref.watch(chatControllerProvider);

    return messagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load messages',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
      data: (messages) {
        if (messages.isEmpty && procState.phase == ChatProcessingPhase.idle) {
          return _EmptyState(onSendChip: widget.onSendChip);
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (scroll) {
            if (scroll is ScrollUpdateNotification) {
              if (_scrollController.hasClients) {
                final nearBottom = _scrollController.position.pixels >=
                    _scrollController.position.maxScrollExtent - 100;
                _autoScroll = nearBottom;
              }
            }
            return false;
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            itemCount: messages.length + (_isProcessing(procState) ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < messages.length) {
                return _buildMessageItem(messages[index]);
              }
              return _buildProcessingItem(procState);
            },
          ),
        );
      },
    );
  }

  bool _isProcessing(ChatProcessingState state) {
    return state.phase != ChatProcessingPhase.idle &&
        state.sessionId == widget.sessionId;
  }

  Widget _buildMessageItem(ChatMessage msg) {
    final isUser = msg.role == 'user';

    if (isUser) {
      return ChatMessageBubble(
        isUser: true,
        child: Text(msg.content),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChatMessageBubble(
          isUser: false,
          showCopy: true,
          copyText: msg.content,
          child: Text(msg.content),
        ),
      ],
    );
  }

  Widget _buildProcessingItem(ChatProcessingState state) {
    if (state.phase == ChatProcessingPhase.thinking) {
      return const ThinkingTracePanel(isThinking: true);
    }

    if (state.phase == ChatProcessingPhase.streaming) {
      final content = state.fullContent ?? '';
      final displayed = content.substring(
        0,
        _streamDisplayCount.clamp(0, content.length),
      );
      final isComplete = _streamDisplayCount >= content.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThinkingTracePanel(
            isThinking: false,
            autoCollapsed: isComplete,
          ),
          ChatMessageBubble(
            isUser: false,
            child: isComplete
                ? Text(content)
                : _StreamingDisplay(
                    displayedText: displayed,
                    hasMore: !isComplete,
                  ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _StreamingDisplay extends StatelessWidget {
  final String displayedText;
  final bool hasMore;

  const _StreamingDisplay({
    required this.displayedText,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(child: Text(displayedText)),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: _BlinkingCaret(),
          ),
      ],
    );
  }
}

class _BlinkingCaret extends StatefulWidget {
  @override
  State<_BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<_BlinkingCaret>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 1.5,
        height: 16,
        color: AppColors.primary,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onSendChip;

  const _EmptyState({required this.onSendChip});

  static const _examples = [
    'What are the INTRA milestones?',
    'How do I submit my logbook?',
    'When is the internship deadline?',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.auto_awesome,
                size: 22,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'How can I help today?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.25,
                color: context.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            ..._examples.map(
              (example) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => onSendChip(example),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: context.surface,
                      border: Border.all(color: context.outline),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      example,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
