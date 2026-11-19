import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_controller.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_session_drawer.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _messageCtrl = TextEditingController();
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
    super.dispose();
  }

  Future<void> _initSession() async {
    final sessions = await ref.read(sessionsProvider.future);
    if (sessions.isNotEmpty) {
      if (mounted) setState(() => _currentSessionId = sessions.first.id);
    } else {
      final id = await ref
          .read(sessionsProvider.notifier)
          .findOrCreateSession();
      if (mounted) setState(() => _currentSessionId = id);
    }
  }

  Future<void> _createNewSession() async {
    ref.read(chatControllerProvider.notifier).cancel();

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
      if (mounted) setState(() => _currentSessionId = id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create new session')),
        );
      }
    }
  }

  void _switchSession(String sessionId) {
    ref.read(chatControllerProvider.notifier).cancel();
    setState(() => _currentSessionId = sessionId);
    Navigator.pop(context);
  }

  Future<void> _deleteSession(String sessionId) async {
    ref.read(chatControllerProvider.notifier).cancel();
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
        .read(chatControllerProvider.notifier)
        .sendMessage(sessionId: _currentSessionId!, content: text);
    _messageCtrl.clear();
  }

  void _stopProcessing() {
    ref.read(chatControllerProvider.notifier).stopStreaming();
  }

  void _sendChipMessage(String text) {
    if (_currentSessionId == null) return;
    _messageCtrl.text = text;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final procState = ref.watch(chatControllerProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Buddy'),
        leading: IconButton(
          icon: const Icon(Icons.dehaze),
          tooltip: 'Chat History',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Chat',
            onPressed: _createNewSession,
          ),
        ],
      ),
      drawer: ChatSessionDrawer(
        currentSessionId: _currentSessionId,
        onSessionSelected: _switchSession,
        onNewSession: _createNewSession,
        onDeleteSession: _deleteSession,
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentSessionId == null
                ? const Center(child: CircularProgressIndicator())
                : ChatMessageList(
                    sessionId: _currentSessionId!,
                    onSendChip: _sendChipMessage,
                  ),
          ),
          ChatComposer(
            controller: _messageCtrl,
            isProcessing: procState.phase != ChatProcessingPhase.idle,
            onSend: _sendMessage,
            onStop: _stopProcessing,
          ),
        ],
      ),
    );
  }
}
