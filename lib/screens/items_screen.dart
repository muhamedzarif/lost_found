import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'item_detail_screen.dart';
import 'dart:convert';

class ItemsScreen extends StatefulWidget {
  final String initialFilter;
  const ItemsScreen({super.key, this.initialFilter = 'all'});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen>
    with SingleTickerProviderStateMixin {
  List lostItems = [];
  List foundItems = [];
  bool loading = true;
  bool showLostFolder = true;
  bool showFoundFolder = true;
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
    fetchItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchItems() async {
    setState(() => loading = true);
    try {
      final allData = await Supabase.instance.client
          .from('items')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        lostItems = allData.where((item) => item['type'] == 'lost').toList();
        foundItems = allData.where((item) => item['type'] == 'found').toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
                        child: const Text(
                          'Item Gallery',
                          style: TextStyle(
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
                      : RefreshIndicator(
                          onRefresh: fetchItems,
                          color: const Color(0xFFB8A9E8),
                          backgroundColor: Colors.white,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Lost Items Folder
                                _FolderSection(
                                  title: 'Lost Items',
                                  icon: Icons.search_rounded,
                                  color: const Color(0xFFFF6B6B),
                                  itemCount: lostItems.length,
                                  isExpanded: showLostFolder,
                                  onToggle: () {
                                    setState(() => showLostFolder = !showLostFolder);
                                  },
                                  isDark: isDark,
                                  child: showLostFolder
                                      ? Column(
                                          children: lostItems.asMap().entries.map((entry) {
                                            final index = entry.key;
                                            final item = entry.value;
                                            return TweenAnimationBuilder<double>(
                                              duration: Duration(milliseconds: 300 + (index * 100)),
                                              tween: Tween(begin: 0.0, end: 1.0),
                                              curve: Curves.easeOutCubic,
                                              builder: (context, value, child) {
                                                return Opacity(
                                                  opacity: value,
                                                  child: Transform.translate(
                                                    offset: Offset(0, 30 * (1 - value)),
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              child: _LofiItemCard(
                                                item: item,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                                          ItemDetailScreen(
                                                        item: item,
                                                      ),
                                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                        const begin = Offset(1.0, 0.0);
                                                        const end = Offset.zero;
                                                        const curve = Curves.easeInOutCubic;
                                                        var tween = Tween(begin: begin, end: end)
                                                            .chain(CurveTween(curve: curve));
                                                        return SlideTransition(
                                                          position: animation.drive(tween),
                                                          child: FadeTransition(
                                                            opacity: animation,
                                                            child: child,
                                                          ),
                                                        );
                                                      },
                                                      transitionDuration: const Duration(milliseconds: 400),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                const SizedBox(height: 20),
                                // Found Items Folder
                                _FolderSection(
                                  title: 'Found Items',
                                  icon: Icons.check_circle_rounded,
                                  color: const Color(0xFF51CF66),
                                  itemCount: foundItems.length,
                                  isExpanded: showFoundFolder,
                                  onToggle: () {
                                    setState(() => showFoundFolder = !showFoundFolder);
                                  },
                                  isDark: isDark,
                                  child: showFoundFolder
                                      ? Column(
                                          children: foundItems.asMap().entries.map((entry) {
                                            final index = entry.key;
                                            final item = entry.value;
                                            return TweenAnimationBuilder<double>(
                                              duration: Duration(milliseconds: 300 + (index * 100)),
                                              tween: Tween(begin: 0.0, end: 1.0),
                                              curve: Curves.easeOutCubic,
                                              builder: (context, value, child) {
                                                return Opacity(
                                                  opacity: value,
                                                  child: Transform.translate(
                                                    offset: Offset(0, 30 * (1 - value)),
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              child: _LofiItemCard(
                                                item: item,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                                          ItemDetailScreen(
                                                        item: item,
                                                      ),
                                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                        const begin = Offset(1.0, 0.0);
                                                        const end = Offset.zero;
                                                        const curve = Curves.easeInOutCubic;
                                                        var tween = Tween(begin: begin, end: end)
                                                            .chain(CurveTween(curve: curve));
                                                        return SlideTransition(
                                                          position: animation.drive(tween),
                                                          child: FadeTransition(
                                                            opacity: animation,
                                                            child: child,
                                                          ),
                                                        );
                                                      },
                                                      transitionDuration: const Duration(milliseconds: 400),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      : const SizedBox.shrink(),
                                ),
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

class _LofiItemCard extends StatefulWidget {
  final dynamic item;
  final VoidCallback onTap;

  const _LofiItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  State<_LofiItemCard> createState() => _LofiItemCardState();
}

class _LofiItemCardState extends State<_LofiItemCard>
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
    final isLost = widget.item['type'] == 'lost';
    final cardGradient = isLost
        ? [const Color(0xFFFF6B6B), const Color(0xFFFF8787)]
        : [const Color(0xFF51CF66), const Color(0xFF69DB7C)];

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(_isHovered ? -0.02 : 0) // 3D tilt
              ..translate(0.0, _isHovered ? -8.0 : 0.0)
              ..scale(_scaleAnimation.value),
            margin: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTapDown: (_) => _scaleController.forward(),
              onTapUp: (_) {
                _scaleController.reverse();
                Future.delayed(const Duration(milliseconds: 100), () {
                  widget.onTap();
                });
              },
              onTapCancel: () => _scaleController.reverse(),
              child: child,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isHovered
                ? [
                    cardGradient[0],
                    cardGradient[1],
                  ]
                : [
                    cardGradient[0].withOpacity(0.7),
                    cardGradient[1].withOpacity(0.7),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: cardGradient[0].withOpacity(_isHovered ? 0.35 : 0.2),
              blurRadius: _isHovered ? 25 : 15,
              offset: Offset(0, _isHovered ? 12 : 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                // Image or Icon
                widget.item['image_data'] != null
                    ? Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.memory(
                            base64Decode(widget.item['image_data']),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                isLost
                                    ? Icons.search_rounded
                                    : Icons.check_circle_rounded,
                                size: 32,
                                color: cardGradient[0],
                              );
                            },
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          isLost
                              ? Icons.search_rounded
                              : Icons.check_circle_rounded,
                          size: 32,
                          color: cardGradient[0],
                        ),
                      ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item['title'] ?? 'Untitled',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.item['description'] ?? 'No description provided',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.item['location'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.85),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By: ${widget.item['user_email'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.75),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 18,
                ),
          ],
        ),
      ),
    );
  }
}

// Folder Section Widget
class _FolderSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int itemCount;
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool isDark;
  final Widget child;

  const _FolderSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.itemCount,
    required this.isExpanded,
    required this.onToggle,
    required this.isDark,
    required this.child,
  });

  @override
  State<_FolderSection> createState() => _FolderSectionState();
}

class _FolderSectionState extends State<_FolderSection>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateX(_isHovered ? -0.015 : 0) // subtle 3D tilt
          ..translate(0.0, _isHovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.color.withOpacity(_isHovered ? 0.3 : 0.2),
              widget.color.withOpacity(_isHovered ? 0.2 : 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.color.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(_isHovered ? 0.25 : 0.15),
              blurRadius: _isHovered ? 20 : 12,
              offset: Offset(0, _isHovered ? 8 : 6),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: widget.onToggle,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: widget.color.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.isDark
                                  ? Colors.white
                                  : const Color(0xFF2D2438),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.itemCount} item${widget.itemCount != 1 ? "s" : ""}',
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.isDark
                                  ? Colors.white.withOpacity(0.7)
                                  : const Color(0xFF2D2438).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: widget.isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.color,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: widget.isExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  top: 8,
                ),
                child: widget.child,
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
