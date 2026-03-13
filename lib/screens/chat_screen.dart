import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/avatar_utils.dart';
import '../utils/batman_style.dart';
import '../widgets/user_avatar.dart';

class ChatScreen extends StatefulWidget {
  final String itemId;
  final String itemTitle;

  const ChatScreen({
    super.key,
    required this.itemId,
    required this.itemTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController messageController = TextEditingController();
  List messages = [];
  bool loading = true;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();

    fetchMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> fetchMessages() async {
    try {
      final data = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('item_id', widget.itemId)
          .order('created_at', ascending: true);

      if (!mounted) return;
      setState(() {
        messages = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(batmanSnackBar(context, 'Unable to load messages: $e'));
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(batmanSnackBar(context, 'You must be logged in to chat.'));
      return;
    }

    try {
      await Supabase.instance.client.from('messages').insert({
        'item_id': widget.itemId,
        'message': text,
        'user_email': currentUser.email,
      });

      messageController.clear();
      await fetchMessages();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(batmanSnackBar(context, 'Failed to send message: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);
    final currentEmail = Supabase.instance.client.auth.currentUser?.email;

    return Scaffold(
      body: Container(
        decoration: batmanBackgroundDecoration(context),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.itemTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Item Conversation',
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: palette.accent,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: palette.accent,
                          ),
                        )
                      : messages.isEmpty
                      ? Center(
                          child: Text(
                            'No messages yet.',
                            style: TextStyle(color: palette.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          itemCount: messages.length,
                          itemBuilder: (_, index) {
                            final msg = messages[index];
                            final isMe = msg['user_email'] == currentEmail;
                            return _MessageBubble(
                              message: msg['message'] ?? '',
                              email: msg['user_email'] ?? 'unknown',
                              isMe: isMe,
                              isDark:
                                  Theme.of(context).brightness ==
                                  Brightness.dark,
                            );
                          },
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.surface,
                  border: Border(top: BorderSide(color: palette.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        style: TextStyle(color: palette.textPrimary),
                        decoration: batmanInputDecoration(
                          context,
                          label: 'Message',
                          icon: Icons.message_outlined,
                          hint: 'Type message',
                        ),
                        onSubmitted: (_) => sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: sendMessage,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(56, 52),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final String email;
  final bool isMe;
  final bool isDark;

  const _MessageBubble({
    required this.message,
    required this.email,
    required this.isMe,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final bgColor = isMe ? palette.accentMuted : palette.surface;
    final textColor = isMe ? Colors.white : palette.textPrimary;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              UserAvatar(
                avatarIcon: AvatarUtils.getAvatarFromEmail(email),
                size: 30,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
            ],
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.62,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: Radius.circular(isMe ? 12 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 12),
                  ),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email,
                      style: TextStyle(
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.8)
                            : palette.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(color: textColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              UserAvatar(
                avatarIcon: AvatarUtils.getAvatarFromEmail(email),
                size: 30,
                isDark: isDark,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
