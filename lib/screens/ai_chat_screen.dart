import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/chat_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  final ChatService _chatService = ChatService();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    setState(() {
      _messages.add({
        'isAi': false,
        'text': text,
        'time': TimeOfDay.now().format(context),
      });
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Call real API
    final response = await _chatService.sendMessage(
      userName: user?.name ?? 'Student',
      message: text,
      userRole: user?.role ?? 'student',
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'isAi': true,
          'text': response,
          'time': TimeOfDay.now().format(context),
        });
      });
      _scrollToBottom();
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final user = authProvider.user;

    return Column(
      children: [
        // Welcome Header
        Container(
          padding: const EdgeInsets.all(20),
          color: isDark
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.primary.withOpacity(0.05),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.name.split(' ')[0] ?? 'Student'}!',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.textPrimary
                            : AppTheme.lightTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'How can I help you today?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: AppTheme.textMuted),
                onPressed: () => setState(() => _messages.clear()),
                tooltip: 'Clear Chat',
              ),
            ],
          ),
        ),

        // Chat History
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildMessageBubble(msg, isDark);
                  },
                ),
        ),

        // Typing Indicator
        if (_isTyping)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI is thinking...',
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.textMuted
                        : AppTheme.lightTextMuted,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

        // Message Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            border: Border(
              top: BorderSide(
                color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                    .withOpacity(0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  onSubmitted: (_) => _sendMessage(),
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.textPrimary
                        : AppTheme.lightTextPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your question...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppTheme.textMuted
                          : AppTheme.lightTextMuted,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: AppTheme.primary,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isDark) {
    bool isAi = msg['isAi'] as bool;
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isAi
              ? Theme.of(context).scaffoldBackgroundColor
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isAi ? 0 : 20),
            bottomRight: Radius.circular(isAi ? 20 : 0),
          ),
          border: isAi
              ? Border.all(
                  color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                      .withOpacity(0.3),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAi)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AI Assistant',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    onPressed: () => _copyToClipboard(msg['text'] as String),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            if (isAi) const SizedBox(height: 8),
            Text(
              msg['text'] as String,
              style: TextStyle(
                color: isAi
                    ? (isDark
                          ? AppTheme.textPrimary
                          : AppTheme.lightTextPrimary)
                    : Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                msg['time'] as String,
                style: TextStyle(
                  color: isAi
                      ? AppTheme.textMuted
                      : Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                color: isDark
                    ? AppTheme.textPrimary
                    : AppTheme.lightTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything about your lectures, schedules, or university life!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
