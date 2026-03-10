import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String itemId;
  final String itemTitle;
  const ChatScreen({super.key, required this.itemId, required this.itemTitle});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final messageController = TextEditingController();
  List messages = [];
  bool loading = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
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
    final data = await Supabase.instance.client
        .from('messages')
        .select()
        .eq('item_id', widget.itemId)
        .order('created_at', ascending: true);
    setState(() {
      messages = data;
      loading = false;
    });
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;
    await Supabase.instance.client.from('messages').insert({
      'item_id': widget.itemId,
      'message': messageController.text.trim(),
      'user_email': Supabase.instance.client.auth.currentUser!.email,
    });
    messageController.clear();
    fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF1A1625),
                    Color(0xFF2D2438),
                    Color(0xFF3D2F4D),
                    Color(0xFF2D2438),
                  ]
                : const [
                    Color(0xFFE8D5F2),
                    Color(0xFFF5E6FF),
                    Color(0xFFFFE5F1),
                    Color(0xFFFFF5E5),
                  ],
            stops: const [0.0, 0.33, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF2D2438).withOpacity(0.6),
                            const Color(0xFF3D2F4D).withOpacity(0.4),
                          ]
                        : [
                            Colors.white.withOpacity(0.5),
                            Colors.white.withOpacity(0.3),
                          ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? const Color(0xFFB8A9E8).withOpacity(0.2)
                          : Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3D2F4D).withOpacity(0.8)
                              : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFFB8A9E8).withOpacity(0.3)
                                : Colors.white.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: isDark
                              ? const Color(0xFFD4C5F9)
                              : const Color(0xFF9B7DC6),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.itemTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFD4C5F9)
                                  : const Color(0xFF9B7DC6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Chat Room',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFFB8A9E8).withOpacity(0.7)
                                  : const Color(0xFF9B7DC6).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF4A3D5C).withOpacity(0.5),
                                  const Color(0xFF5B4670).withOpacity(0.5),
                                ]
                              : [
                                  const Color(0xFFB8A9E8).withOpacity(0.3),
                                  const Color(0xFFE8B8D5).withOpacity(0.3),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: isDark
                            ? const Color(0xFFD4C5F9)
                            : const Color(0xFF9B7DC6),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              // Messages
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: loading
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF3D2F4D).withOpacity(0.8)
                                  : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const CircularProgressIndicator(
                              color: Color(0xFFB8A9E8),
                            ),
                          ),
                        )
                      : messages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 70,
                                    color: isDark
                                        ? const Color(0xFFB8A9E8)
                                            .withOpacity(0.3)
                                        : const Color(0xFF9B7DC6)
                                            .withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No messages yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark
                                          ? const Color(0xFFB8A9E8)
                                              .withOpacity(0.7)
                                          : const Color(0xFF9B7DC6)
                                              .withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Start the conversation! ✨',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? const Color(0xFFB8A9E8)
                                              .withOpacity(0.6)
                                          : const Color(0xFF9B7DC6)
                                              .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              physics: const BouncingScrollPhysics(),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                final isMe = msg['user_email'] ==
                                    Supabase.instance.client.auth.currentUser!
                                        .email;
                                return TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 200 + (index * 50)),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(isMe ? 30 * (1 - value) : -30 * (1 - value), 0),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _MessageBubble(
                                    message: msg['message'],
                                    email: msg['user_email'],
                                    isMe: isMe,
                                  ),
                                );
                              },
                            ),
                ),
              ),
              // Input Area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF2D2438).withOpacity(0.7),
                            const Color(0xFF3D2F4D).withOpacity(0.5),
                          ]
                        : [
                            Colors.white.withOpacity(0.7),
                            Colors.white.withOpacity(0.5),
                          ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? const Color(0xFFB8A9E8).withOpacity(0.2)
                          : Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3D2F4D).withOpacity(0.6)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB8A9E8).withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: messageController,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? const Color(0xFFE8E0F5)
                                : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? const Color(0xFFB8A9E8).withOpacity(0.4)
                                  : const Color(0xFF9B7DC6).withOpacity(0.4),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (_) => sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _SendButton(onPressed: sendMessage),
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

class _MessageBubble extends StatefulWidget {
  final String message;
  final String email;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.email,
    required this.isMe,
  });

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Align(
        alignment:
            widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.02 : 1.0),
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isMe
                  ? _isHovered
                      ? [
                          const Color(0xFFD1A9E8),
                          const Color(0xFFE89BC9),
                        ]
                      : [
                          const Color(0xFFB8A9E8),
                          const Color(0xFFD1A9E8),
                        ]
                  : _isHovered
                      ? [
                          Colors.white,
                          Colors.white.withOpacity(0.9),
                        ]
                      : [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.8),
                        ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(widget.isMe ? 20 : 4),
              bottomRight: Radius.circular(widget.isMe ? 4 : 20),
            ),
            border: Border.all(
              color: widget.isMe
                  ? Colors.white.withOpacity(0.5)
                  : const Color(0xFFB8A9E8).withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isMe
                    ? const Color(0xFFB8A9E8).withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered ? 15 : 10,
                offset: Offset(0, _isHovered ? 6 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.email,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isMe
                      ? Colors.white.withOpacity(0.8)
                      : const Color(0xFF9B7DC6).withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: 15,
                  color: widget.isMe ? Colors.white : const Color(0xFF9B7DC6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _SendButton({required this.onPressed});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * (_isHovered ? 1.1 : 1.0),
            child: GestureDetector(
              onTapDown: (_) => _scaleController.forward(),
              onTapUp: (_) {
                _scaleController.reverse();
                Future.delayed(const Duration(milliseconds: 100), () {
                  widget.onPressed();
                });
              },
              onTapCancel: () => _scaleController.reverse(),
              child: child,
            ),
          );
        },
        child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isHovered
                    ? [
                        const Color(0xFFD1A9E8),
                        const Color(0xFFE89BC9),
                      ]
                    : [
                        const Color(0xFFB8A9E8),
                        const Color(0xFFD1A9E8),
                      ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB8A9E8)
                      .withOpacity(_isHovered ? 0.4 : 0.2),
                  blurRadius: _isHovered ? 15 : 10,
                  offset: Offset(0, _isHovered ? 6 : 4),
                ),
              ],
            ),
          child: const Icon(
            Icons.send_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}