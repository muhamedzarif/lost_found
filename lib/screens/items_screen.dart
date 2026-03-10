import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';
import 'dart:convert';

class ItemsScreen extends StatefulWidget {
  final String initialFilter;
  const ItemsScreen({super.key, this.initialFilter = 'all'});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen>
    with SingleTickerProviderStateMixin {
  List items = [];
  bool loading = true;
  late String filter;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    filter = widget.initialFilter;
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
      final query = Supabase.instance.client.from('items').select();

      final data = filter == 'all'
          ? await query.order('created_at', ascending: false)
          : await query.eq('type', filter).order('created_at', ascending: false);

      setState(() {
        items = data;
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
                    _FilterButton(
                      currentFilter: filter,
                      onFilterChanged: (value) {
                        setState(() => filter = value);
                        fetchItems();
                      },
                      isDark: isDark,
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
                      : items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 80,
                                    color: isDark
                                        ? const Color(0xFFB8A9E8)
                                            .withOpacity(0.3)
                                        : const Color(0xFF9B7DC6)
                                            .withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No items found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: isDark
                                          ? const Color(0xFFB8A9E8)
                                              .withOpacity(0.7)
                                          : const Color(0xFF9B7DC6)
                                              .withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: fetchItems,
                              color: const Color(0xFFB8A9E8),
                              backgroundColor: Colors.white,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return _LofiItemCard(
                                    item: item,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(
                                            itemId: item['id'].toString(),
                                            itemTitle: item['title'] ?? 'Chat',
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
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

class _LofiItemCardState extends State<_LofiItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isLost = widget.item['type'] == 'lost';
    final cardGradient = isLost
        ? [const Color(0xFFFFB6D9), const Color(0xFFFFD6E8)]
        : [const Color(0xFFB8E8D4), const Color(0xFFD4F1E8)];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -6.0 : 0.0),
        margin: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: widget.onTap,
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
                        widget.item['description'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
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
        ),
      ),
    );
  }
}

class _FilterButton extends StatefulWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;
  final bool isDark;

  const _FilterButton({
    required this.currentFilter,
    required this.onFilterChanged,
    required this.isDark,
  });

  @override
  State<_FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<_FilterButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: PopupMenuButton<String>(
        initialValue: widget.currentFilter,
        onSelected: widget.onFilterChanged,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: widget.isDark
            ? const Color(0xFF3D2F4D).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isHovered
                  ? [
                      const Color(0xFFB8A9E8),
                      const Color(0xFFD1A9E8),
                    ]
                  : widget.isDark
                      ? [
                          const Color(0xFF3D2F4D).withOpacity(0.8),
                          const Color(0xFF4A3D5C).withOpacity(0.8),
                        ]
                      : [
                          Colors.white.withOpacity(0.7),
                          Colors.white.withOpacity(0.6),
                        ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isDark
                  ? const Color(0xFFB8A9E8).withOpacity(0.3)
                  : Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: _isHovered
                    ? Colors.white
                    : (widget.isDark
                        ? const Color(0xFFD4C5F9)
                        : const Color(0xFF9B7DC6)),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                _getFilterLabel(widget.currentFilter),
                style: TextStyle(
                  color: _isHovered
                      ? Colors.white
                      : (widget.isDark
                          ? const Color(0xFFD4C5F9)
                          : const Color(0xFF9B7DC6)),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        itemBuilder: (context) => [
          _buildMenuItem('all', 'All Items', Icons.inventory_2_outlined),
          _buildMenuItem('lost', 'Lost Items', Icons.search_rounded),
          _buildMenuItem('found', 'Found Items', Icons.check_circle_rounded),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      String value, String label, IconData icon) {
    final isSelected = widget.currentFilter == value;
    final isDark = widget.isDark;
    return PopupMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    const Color(0xFFB8A9E8).withOpacity(0.2),
                    const Color(0xFFD1A9E8).withOpacity(0.2),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark
                      ? const Color(0xFFD4C5F9)
                      : const Color(0xFF9B7DC6))
                  : (isDark
                      ? const Color(0xFFB8A9E8).withOpacity(0.5)
                      : const Color(0xFF9B7DC6).withOpacity(0.5)),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (isDark
                        ? const Color(0xFFD4C5F9)
                        : const Color(0xFF9B7DC6))
                    : (isDark
                        ? const Color(0xFFB8A9E8).withOpacity(0.7)
                        : const Color(0xFF9B7DC6).withOpacity(0.7)),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'lost':
        return 'Lost';
      case 'found':
        return 'Found';
      default:
        return 'All';
    }
  }
}
