import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';
import 'dart:convert';

class ItemDetailScreen extends StatefulWidget {
  final dynamic item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> deleteItem() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You must be logged in to delete items'),
            backgroundColor: const Color(0xFFFF9EC9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }

    // Check if user owns this item (check both user_id and user_email for backwards compatibility)
    final isOwner = (widget.item['user_id'] != null && widget.item['user_id'] == currentUser.id) ||
                    (widget.item['user_email'] != null && widget.item['user_email'] == currentUser.email);
    
    if (!isOwner) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You can only delete your own items'),
            backgroundColor: const Color(0xFFFF9EC9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark
              ? const Color(0xFF2D2438)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark
                  ? const Color(0xFFB8A9E8).withOpacity(0.3)
                  : const Color(0xFF9B7DC6).withOpacity(0.3),
              width: 2,
            ),
          ),
          title: Text(
            'Delete Item?',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF2D2438),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${widget.item['title']}"? This action cannot be undone.',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.8)
                  : const Color(0xFF2D2438).withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFD4C5F9)
                      : const Color(0xFF9B7DC6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Delete the item
    try {
      await Supabase.instance.client
          .from('items')
          .delete()
          .eq('id', widget.item['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Item deleted successfully'),
            backgroundColor: const Color(0xFFB8E8D4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        // Go back to previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting item: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF9EC9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  bool _isOwner() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return false;
    
    return (widget.item['user_id'] != null && widget.item['user_id'] == currentUser.id) ||
           (widget.item['user_email'] != null && widget.item['user_email'] == currentUser.email);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLost = widget.item['type'] == 'lost';
    final itemColor = isLost ? const Color(0xFFFF6B6B) : const Color(0xFF51CF66);

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
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3D2F4D).withOpacity(0.8)
                              : Colors.white.withOpacity(0.7),
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
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF9B7DC6), Color(0xFFE89BC9)],
                        ).createShader(bounds),
                        child: Text(
                          isLost ? 'Lost Item Details' : 'Found Item Details',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type Badge with 3D animation
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform(
                                alignment: Alignment.centerLeft,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY((1 - value) * 0.5)
                                  ..translate((1 - value) * -50.0, 0.0, 0.0),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isLost
                                      ? [
                                          const Color(0xFFFF6B6B),
                                          const Color(0xFFFF8787),
                                        ]
                                      : [
                                          const Color(0xFF51CF66),
                                          const Color(0xFF69DB7C),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isLost
                                            ? const Color(0xFFFF6B6B)
                                            : const Color(0xFF51CF66))
                                        .withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isLost
                                        ? Icons.search_rounded
                                        : Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isLost ? 'Lost Item' : 'Found Item',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Image with 3D flip animation
                          if (widget.item['image_data'] != null)
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateX((1 - value) * 0.5)
                                    ..scale(0.8 + (value * 0.2)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: 250,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF3D2F4D).withOpacity(0.6)
                                      : Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFB8A9E8)
                                          .withOpacity(0.15),
                                      blurRadius: 25,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.memory(
                                    base64Decode(widget.item['image_data']),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          isLost
                                              ? Icons.search_rounded
                                              : Icons.check_circle_rounded,
                                          size: 80,
                                          color: itemColor.withOpacity(0.5),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          if (widget.item['image_data'] != null)
                            const SizedBox(height: 24),
                          // Title Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF3D2F4D).withOpacity(0.6)
                                  : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFFB8A9E8).withOpacity(0.3)
                                    : Colors.white.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFB8A9E8)
                                      .withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item['title'] ?? 'Untitled',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFFE8E0F5)
                                        : const Color(0xFF2D2438),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Description Card
                          _DetailCard(
                            isDark: isDark,
                            title: 'Description',
                            icon: Icons.description_outlined,
                            child: Text(
                              widget.item['description'] ??
                                  'No description provided',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? const Color(0xFFD4C5F9)
                                    : const Color(0xFF2D2438),
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Location Card
                          _DetailCard(
                            isDark: isDark,
                            title: 'Location',
                            icon: Icons.location_on_rounded,
                            child: Text(
                              widget.item['location'] ?? 'Unknown location',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? const Color(0xFFD4C5F9)
                                    : const Color(0xFF2D2438),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Last Seen Card (only for lost items)
                          if (isLost && widget.item['last_seen'] != null && widget.item['last_seen'].toString().isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _DetailCard(
                              isDark: isDark,
                              title: 'Last Seen',
                              icon: Icons.access_time_rounded,
                              child: Text(
                                widget.item['last_seen'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark
                                      ? const Color(0xFFD4C5F9)
                                      : const Color(0xFF2D2438),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          // Posted By Card
                          _DetailCard(
                            isDark: isDark,
                            title: 'Posted By',
                            icon: Icons.person_outline_rounded,
                            child: Text(
                              widget.item['user_email'] ?? 'Unknown user',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? const Color(0xFFD4C5F9)
                                    : const Color(0xFF2D2438),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Contact Button
                          _ContactButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) =>
                                          ChatScreen(
                                    itemId: widget.item['id'].toString(),
                                    itemTitle:
                                        widget.item['title'] ?? 'Chat',
                                  ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    // Smooth slide from bottom with fade
                                    final slideAnimation = Tween<Offset>(
                                      begin: const Offset(0.0, 0.15),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    );
                                    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                      ),
                                    );
                                    return SlideTransition(
                                      position: slideAnimation,
                                      child: FadeTransition(
                                        opacity: fadeAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 300),
                                ),
                              );
                            },
                            label: 'Contact About This Item',
                            isLost: isLost,
                          ),
                          const SizedBox(height: 20),
                          // Delete Button (only show if user owns this item)
                          if (_isOwner())
                            _DeleteButton(
                              onPressed: deleteItem,
                            ),
                          if (_isOwner())
                            const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatefulWidget {
  final bool isDark;
  final String title;
  final IconData icon;
  final Widget child;

  const _DetailCard({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  State<_DetailCard> createState() => _DetailCardState();
}

class _DetailCardState extends State<_DetailCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_isHovered ? -0.01 : 0)
          ..translate(0.0, _isHovered ? -4.0 : 0.0),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isDark
              ? const Color(0xFF3D2F4D).withOpacity(0.6)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isDark
                ? const Color(0xFFB8A9E8).withOpacity(0.3)
                : Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB8A9E8).withOpacity(_isHovered ? 0.15 : 0.1),
              blurRadius: _isHovered ? 25 : 20,
              offset: Offset(0, _isHovered ? 12 : 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.icon,
                  color: widget.isDark
                      ? const Color(0xFFB8A9E8)
                      : const Color(0xFF9B7DC6),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark
                        ? const Color(0xFFB8A9E8)
                        : const Color(0xFF9B7DC6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            widget.child,
          ],
        ),
      ),
    );
  }
}

class _ContactButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLost;

  const _ContactButton({
    required this.onPressed,
    required this.label,
    required this.isLost,
  });

  @override
  State<_ContactButton> createState() => _ContactButtonState();
}

class _ContactButtonState extends State<_ContactButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateX(_isHovered ? -0.05 : 0)
              ..scale(_scaleAnimation.value * (_isHovered ? 1.02 : 1.0)),
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
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isHovered
                  ? widget.isLost
                      ? [
                          const Color(0xFFFF6B6B),
                          const Color(0xFFFF8787),
                        ]
                      : [
                          const Color(0xFF51CF66),
                          const Color(0xFF69DB7C),
                        ]
                  : widget.isLost
                      ? [
                          const Color(0xFFFF5252),
                          const Color(0xFFFF6B6B),
                        ]
                      : [
                          const Color(0xFF40C057),
                          const Color(0xFF51CF66),
                        ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (widget.isLost
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF51CF66))
                    .withOpacity(_isHovered ? 0.4 : 0.3),
                blurRadius: _isHovered ? 25 : 15,
                offset: Offset(0, _isHovered ? 12 : 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.white.withOpacity(0.3),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _DeleteButton({
    required this.onPressed,
  });

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateX(_isHovered ? -0.05 : 0)
              ..scale(_scaleAnimation.value * (_isHovered ? 1.02 : 1.0)),
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
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isHovered
                  ? [
                      const Color(0xFFFF4444),
                      const Color(0xFFFF6B6B),
                    ]
                  : [
                      const Color(0xFFFF3333),
                      const Color(0xFFFF5252),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B6B)
                    .withOpacity(_isHovered ? 0.4 : 0.3),
                blurRadius: _isHovered ? 25 : 15,
                offset: Offset(0, _isHovered ? 12 : 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.white.withOpacity(0.3),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Delete This Item',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
