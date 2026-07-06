import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_controller.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _currentSessionId;
  final _sessionsWithActivity = <String>{};

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _initSession() async {
    final sessions = await ref.read(sessionsProvider.future);
    if (sessions.isNotEmpty) {
      setState(() => _currentSessionId = sessions.first.id);
    } else {
      final id = await ref
          .read(sessionsProvider.notifier)
          .findOrCreateSession();
      if (mounted) {
        setState(() => _currentSessionId = id);
      }
    }
  }

  Future<void> _createNewSession() async {
    if (_currentSessionId != null &&
        !_sessionsWithActivity.contains(_currentSessionId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Send a message first to start a new session'),
        ),
      );
      return;
    }

    try {
      final id = await ref.read(sessionsProvider.notifier).createNewSession();
      if (mounted) {
        setState(() => _currentSessionId = id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create new session')),
        );
      }
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    await ref.read(sessionsProvider.notifier).deleteSession(sessionId);
    if (mounted && _currentSessionId == sessionId) {
      final remaining = await ref.read(sessionsProvider.future);
      if (remaining.isNotEmpty) {
        setState(() => _currentSessionId = remaining.first.id);
      } else {
        await _createNewSession();
      }
    }
  }

  void _sendMessage() {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || _currentSessionId == null) return;

    _sessionsWithActivity.add(_currentSessionId!);
    ref
        .read(chatControllerProvider)
        .sendMessage(sessionId: _currentSessionId!, content: text);
    _messageCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(_currentSessionIdProvider, (prev, next) {});

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.dehaze),
          tooltip: 'Chat History',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message_outlined),
            tooltip: 'New Chat',
            onPressed: _createNewSession,
          ),
        ],
      ),
      drawer: _SessionDrawer(
        currentSessionId: _currentSessionId,
        onSessionSelected: (sessionId) {
          setState(() => _currentSessionId = sessionId);
          Navigator.pop(context);
        },
        onNewSession: _createNewSession,
        onDeleteSession: _deleteSession,
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentSessionId == null
                ? const Center(child: CircularProgressIndicator())
                : _MessageList(sessionId: _currentSessionId!),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.outline)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageCtrl,
                decoration: InputDecoration(
                  hintText: 'Ask a question...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: context.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _currentSessionIdProvider = Provider<String?>((ref) => null);

class _MessageList extends ConsumerWidget {
  final String sessionId;

  const _MessageList({required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesState = ref.watch(messagesProvider(sessionId));

    return messagesState.when(
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
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_outlined, size: 64, color: context.muted),
                const SizedBox(height: 16),
                Text(
                  'How can I help you?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ask me about INTRA procedures, deadlines, and requirements',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: context.muted),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            return _MessageBubble(message: msg);
          },
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: context.primaryContainer,
              child: const Icon(
                Icons.smart_toy,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : context.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser ? null : Border.all(color: context.outline),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : context.onSurface,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _SessionDrawer extends ConsumerWidget {
  final String? currentSessionId;
  final void Function(String sessionId) onSessionSelected;
  final VoidCallback onNewSession;
  final void Function(String sessionId) onDeleteSession;

  const _SessionDrawer({
    this.currentSessionId,
    required this.onSessionSelected,
    required this.onNewSession,
    required this.onDeleteSession,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsState = ref.watch(sessionsProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chat History',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: sessionsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    const Center(child: Text('Failed to load sessions')),
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return Center(
                      child: Text(
                        'No sessions yet',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: context.muted),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final isActive = session.id == currentSessionId;
                      return ListTile(
                        selected: isActive,
                        selectedTileColor: Colors.grey.withAlpha(40),
                        title: Text(
                          session.title ?? 'Chat Session',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => onSessionSelected(session.id),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: AppColors.error,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Session'),
                                content: const Text(
                                  'Are you sure you want to delete this chat session?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      onDeleteSession(session.id);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
